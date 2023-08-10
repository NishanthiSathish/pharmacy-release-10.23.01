Attribute VB_Name = "PatBill"
'Patient Billing Module Stub
'15Feb13 XN  billpatient: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
'            BillPatDispensQty%: Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

DefInt A-Z
Option Explicit
Dim m_blnBillingInitialised As Boolean
'Dim m_strBillingComponent As String
'Dim m_strBillingComponentWrite As String
Dim m_strBillingComponentURL As String
''Global gObjBilling As Object 'Removed after architecture discussions

Dim m_FoundDrugitem As Integer

Dim billOpath$, billOfile$    ' export path/filename
Dim Billitems$()              ' holds all info collected from ques scroll
Dim patiententry%             ' T/F depend on whether found in table
Dim foundDrugitem%            ' T/F depend on whether successfully created snapshot with drug info
Dim FatalErr%                 ' T/F if an error has occured

Dim SequenceNo%
Dim transCount%               ' holds number of transactions (O/P issues) for current patient
Dim populatedQues%

Dim manufacturerspremium!, copayment!, pharmacsubsidy!            ' values calculated that can be modified by the user
Dim sysmanufacturerspremium$, syscopayment$, syspharmacsubsidy$   ' values calculated by the system
Dim patAge!, isContraceptive%, newDispensing%, toDispens!, toOwe!

'16Nov99 SF following added for PBS
Dim SpecialAuthorityNum$, datePrescriptionWritten$
Dim PBSItemStatus$, PBSItemType$
Dim BeneficiaryType$, safetyNetCard$
Dim serialnumber&, PatientCost!, SafetyNetValue!, safeNet%
Dim OriginalDate$, OriginalApprovalNumber$, OriginalScriptNumber$, EPItem%, hicprice!, dispensStatus$, solventPBScode$
Dim debugPBScode$, debugManuCode$, debugPatientCost$, debugSafetyNet$
Dim TimesIssued$ '23Feb03 TH (PBSv4) Added
'16Nov99 SF -----

Dim blnAddToPRF     '24Nov99 SF T/F to decide whether safety net goes towards patient's PRF
Dim origPrescriber$ '16May00 SF/AE

'16Nov00 SF added
Dim serialNumWithPrefix$
Dim PBScode$, manuCode$
Dim billPat%, setUpOk%

Const BillLogFile$ = "\PATBILL.LOG"
Const BillIniFile$ = "\PATBILL.INI"
Const OBJNAME = "Billing"


'16Nov00 SF -----

'31Jan03 TH PBS ver 4
Dim Transcost!
Dim m_sglExceptionalPrice As Single
Dim m_intRepeatInterval As Integer
Dim m_blnPBSDispenseOn  As Integer
Dim m_sglLowMarkUpLevel As Single, m_sglMarkUpLow As Single, m_sglHighMarkUpLevel As Single, m_sglMarkUpHigh As Single, m_sglMarkUpMid As Single
Const ConstPBSDebug = True
Dim m_blnKeepPBSDefaults As Integer
Dim m_blnPBSNewScript As Integer
Dim m_blnKeepBillitems   As Integer
Dim m_strPBSLastDate As String  '03Mar03 TH (PBSv4) Added to retain for the repeat check
Dim m_blnPBSPrivateDispensing  As Integer '09Mar03 TH (PBSv4) Added
'----------------------------
Dim PrescriberTypeList$()
Dim blnPBSSuppressExceptional As Integer '23Jul03 TH Added

Type PBSProduct
   PBSProductID As Long
   DrugID As Long
   DrugTypeCode As String * 2
   ATCCode As String * 20
   ATCType As String * 1
   ATCPrintOption As Long
   PBScode As String * 5
   RestrictionFlag As String * 1
   CautionFlag As String * 1
   NoteFlag As String * 1
   maxqty As Long
   MaxRepeats As Long
   ManufacturersCode As String * 2
   ROP As Long
   brandpremium As Double
   TherapeuticPremium As Double
   CommonWealthPrice As Double
   CommonWealthDispensed As Double
   TherapeuticGroupPrice As Double
   TherapeuticGroupDispensed As Double
   PriceToPharmacy As Double
   DispensedPriceMaxQty As Double
   MaxRecordableValue As Double
   BioEquivelence As String * 1
   BrandName As String * 255
   GenericName As String * 255
   FormAndStrength As String * 255
   SolventRequired As Boolean
   PBSSubsidised As Boolean
   Description As String * 50
   AverageRate As Double
   MaxPricePayable As Double
   MaxPriceToPatients As Double
   IssueUnit As String * 5
End Type

Dim m_PBSProduct As PBSProduct

Type PrescriberStruct
   Code As String * 5
   inuse As Integer
   name As String * 30
   Address1 As String * 30
   Address2 As String * 30
   Address3 As String * 30
   postCode As String * 10
   telephonenumber As String * 20
   specialist As String * 25
   secondaryCode As String * 15
   registrationNumber As String * 15
   datecreated As Date
   prescribertype As String * 5
   freetext As String
End Type

Dim m_Prescriber As PrescriberStruct

Type PBSPatientStruct
   PBSPatientID As Long
   BeneficiaryType As String * 1
   ConcessionNumber As String * 11
   ConcessionExpiry As String * 10
   SafetyNetType As String * 1
   SafetyNetNumber As String * 11
   ThresholdAmount As Double
   PreviousDateDispensed As String * 10
   MedicareNumber As String * 10
   Familygroupnumber As Long
   Subnumerate As String * 1
   MedicareExpirydate As String * 6
   RepatriationNumber As String * 9
   RepatriationCardType As String * 1
   Scripts As Integer
   TemporaryMedicareNumber As String * 10
   TemporaryExpiryDate As String * 6
End Type
Dim m_PBSPatient As PBSPatientStruct

Type PatFeesStruct
   PBSmarkupLow As Double
   PBSmarkupMid As Double
   PBSmarkupHigh As Double
   PBSlowMarkupLevel As Double
   PBShighMarkupLevel As Double
   PrivateMarkup As Double
   PrivateDispensingFee As Double
   CompositeFeeRP As Double
   CompositeFeeEP As Double
   AdditionalFeeRP As Double
   AdditionalFeeEP As Double
   AllowableExtraFee As Double
   GeneralPatient As Double
   ConcessionPatient As Double
   SafetyNetConcession As Double
   SafetyNetEntitlement As Double
   GenPatSafety As Double
   ConPatSafety As Double
   dangerousdrugfee As Double
   containerPrice As Double
   WaterFee As Double
   GenFamSafety As Double
   ConFamSafety As Double
   InjectableContainerPrice As Double
   HSDmarkupLow As Double
   HSDmarkupMid As Double
   HSDmarkupHigh As Double
   HSDlowMarkupLevel As Double
   HSDhighMarkupLevel As Double
End Type
Dim m_PatFees As PatFeesStruct

Type PBSDrugRepeat
   PBSDrugRepeatID As Long
   PatRecNo As Long
   RxNumber As Long
   NumberOfRepeats As Integer
   DispensQty As Double
   QtyOwing As Double
   StopDate As String * 10
   Status As String * 1
   Type As String * 1
   SpecialAuthorityNum As String * 50
   OriginalDate As String * 10
   OriginalApprovalNumber As String * 50
   OriginalScriptNumber As String * 50
   PBScode As String * 5
   ManufacturersCode As String * 2
   SolventCode As String * 50
   ExceptionalPrice As Double
   RepeatInterval As Integer
   OriginalLastIssuedDate As String * 10
   OriginalTimesIssued As Integer
   ExcepDescription As String * 50
   ExcepQty As Integer
   VariableQtys As String * 50
   ACCitem As String * 50
   ItemStatus As String * 50
   RequestID As Long
   NonpBS As Boolean
   NumberOfIssues As Integer
   DrugID As Long
End Type
Dim m_PBSDrugRepeat As PBSDrugRepeat



Sub InitialiseBilling()
'14Mar06 TH Written .
'Should be called by any application using billing methodolgy
'prior to any specific billing calls.
'Here we check the "big switch" and set up the billing component that we are going to use.
'returns true if billing is set up
Dim intNumBillingItems As Integer

   m_blnBillingInitialised = TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "BillPatient", 0))
   If m_blnBillingInitialised Then
      ''m_strBillingComponentURL = TxtD(dispdata$ & "\patbill.ini", "PatientBilling", "", "BillingComponentURL", 0)
      ''m_strBillingComponentURL = "//localhost/ascicw/application/PBS_PatientBilling_aspx/default.aspx"
      ''m_strBillingComponentURL = "http://localhost/ascicw995Test/application/PBS_PatientBilling_aspx/default.aspx"
                                  
      ''m_strBillingComponentURL = "http://ascribetestweb1/v9-9_testing/application/PBS_PatientBilling_aspx/default.aspx"
      m_strBillingComponentURL = TxtD$(dispdata & "\" & "patmed.ini", "PatientBilling", m_strBillingComponentURL, "BillingComponentURL", 0)

      If Trim$(m_strBillingComponentURL) = "" Then
         '01Jun07 TH Added
         m_blnBillingInitialised = False
         popmessagecr "Patient Billing", "Patient Billing is configured for this site but the Billing Component Setting has not been recorded" _
         & crlf & crlf & "Please report this to your system mananger"
      Else
         
         intNumBillingItems = Val(TxtD(dispdata$ & "\patbill.ini", "Data", "0", "Total", 0))
         If intNumBillingItems = 0 Then
            'everythingOk% = False
            popmessagecr ".Patient Billing", "[Data] Total not setup correctly" & cr & "Cannot bill on any further drugs dispensed"
            m_blnBillingInitialised = False
         Else
            ReDim Billitems$(intNumBillingItems)
            ''m_strBillingComponentWrite = TxtD(dispdata$ & "\patbill.ini", "PatientBilling", "", "BillingComponentWrite", 0)
            'PBSGetPatientDetails
            m_blnKeepPBSDefaults = False
            m_blnPBSDispenseOn = True
            If isPBS() Then
               PBSGetFeesDetails
               'GetCurrentPrescriberDetails
               m_blnPBSDispenseOn = True
            End If
         End If

      End If
   End If
   
   ''InitialiseBilling = blnBillingInitialised
   
End Sub
Function billpatient(action%, txtReturn$) As Variant
Dim DT1 As DateAndTime     '16Nov99 SF added
Dim SQL$, repeats%
Dim escd As Integer
Dim blnEscaped As Boolean
Dim Value!, Owed!, origDispens!
Dim myError$, myErr%                      '16Nov99 SF added
'Dim db As database                        '16Nov99 SF added   '08Mar03 TH/ATW removed
''Dim snap As Snapshot                      '16Nov99 SF added
''Dim dyn As dynaset                        '16Nov00 SF added
Dim txt$, drugName$, Status$, Out$        '16Nov99 SF added
Dim billit%, valid%, drugrepeats%, X%, minsToday&, restriction$, tmpLabf&, numDays& '  '16Nov99 SF added  '08Mar03 TH/ATW removed   PBSrange% ,lineChosen%
Dim tmpQty!    '# SF added
Dim totalValue!         '16Nov00 SF added
'23Jan01 SF added
Dim lines$()
Dim numoflines%
'23Jan01 SF -----
Dim strDateReceived As String, strAns As String    '04Mar02 TH Added (#MOJ#)
Dim strAuthNum As String, strOrigNum As String   '31Jan03 TH (PBSv4) Added
Dim sglSafetyNetValue As Single '07Apr03 TH (PBSv4) Added
''Dim snapcheck As Snapshot  '24Jun03 TH Added
Dim strDescription As String '24Jun03 TH Added
Dim intloop As Integer    '10Aug05 TH Added
Dim NumLabels As Integer  '  "
Dim lngCount As Long
Dim lngOK As Long
Dim blnAlreadyPrescribed As Boolean
Dim objBilling As Object
Dim strStatus As String
Dim intBillingtype As Integer


' action:
'        0 = when loading the patient to set defaults, load patient info etc.
'        1 = when an item is issued to a patient
'        2 = when unloading the patient to save patient info, print invoices etc.
'        3 = warn before issue if reached maximum number of repeats
'        4 = set Qty! to the current dispensing qty (done this way to encapsulate Patbill from the main program)
'        5 = a label is being re-used so delete all repeat info from previous dispensings
'        6 = discontinue the medication if all repeats dispensed and no owes
'        7 = adds the repeat number to the prescription id on the pmr label
'        8 = displays relevant patient billing info on the F3 "Further Information" screen on the PMR
'        9 = put the max qty to issue automatically in the issue box for PBS items
'       10 = ensure that if user overrides the max qty then the drug is either authority or private
'       11 = gets the date the prescriber wrote the prescription (ensures this is not >12 months)
'       12 = ensures the same drug is not prescribed twice in the same day for the same patient
'       13 = returns True/False if PBS billing is setup
'       14 = when returning an item(F9) roll back PBS info (ie. #repeats given etc.)
'       15 = get the correct PBS code from the NSV code given
'       16 = populate the formula table with one of the 3 char manufacturing(EP) PBS codes
'*      17 = clears patient billing data elements
'*      18 = returns original prescriber code on repeats (regardless of the current prescriber code)
'04Mar02 TH (#MOJ#)
'       23 = returns whether label is owing or not for type 3 (MOJ)
'       24 = sets owing to received and records received date for type 3 (MOJ)
'12Sep02 ATW changed comments below for improved accuracy, changed overlapping constant
'19Sep02 ATW
'       25 = returns if MOJ set up (left uncommented previously)
'       26 = executes an invoice print
'       27 = checks to see if this patient is valid for billing

'''   '07Jan00 SF added to ensure exiting if patient billing not setup
'''   If Not TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0)) Then
'''         billpatient = False
'''         Exit Function
'''      Else     '25Apr02 ATW Added.
'''         billingtype% = Val(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "", "BillingType", 0))
'''      End If
'''   '07Jan00 SF -----
'
'   15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)
   
   ''On Error GoTo PatBillErr

   If action <> 0 And FatalErr% Then GoTo PatBillExit
   '17May02 ATW   Switch to Flexible Billing System and avoid all that \/
'''   If billingtype = 4 Then
'''         billpatient = BmiBillPatient(action%, txtReturn$)
'''         Exit Function
'''      End If

   escd = False


   drugName$ = Trim$(d.LabelDescription)	' drugName$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
   plingparse drugName$, "!"
   

   billit = False
   If m_blnBillingInitialised = True Then
      billit = ItemForBilling()
      intBillingtype = Val(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "", "BillingType", 0))
   Else
      Exit Function
   End If
  
   
   Select Case action%

      Case 0:
''         billPat% = TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0))
''         If billPat% Then setUpOk% = PatientBillingSetupOk()

      'Case 1:
      Case 1, 19, 20, 32, 34, 35: '31Jan03 TH (PBSv4) Added 32  '17Mar03 TH (PBSv4) Added 34  '23Jul03 TH Added 35
         'If billPat% = True And setUpOk% = True And pid.status = "O" Then    '16Nov99 SF replaced
         
         If billit Then                                                       '16Nov99 SF
               repeats% = NumberOfRepeats%()
               If FatalErr% Then GoTo PatBillExit
               
                     '01Jun07 TH If (newDispensing% = True) And (repeats% <> -1) And ((L.batchnumber > repeats) And repeats <> 0) Then '31Jan03 TH (PBSv4) Added
                     If (newDispensing% = True) And (repeats% <> -1) And ((m_PBSDrugRepeat.NumberOfIssues > repeats) And repeats <> 0) Then '31Jan03 TH (PBSv4) Added
                           ' issued all repeats allowed for this item
                           '''ClearPatBillLbl
                           escd = True    '16Nov00 SF added
                        Else
                              If newDispensing% Then m_intRepeatInterval = 0  '31Jan03 TH (PBSv4) Added
                              If action% = 19 Then escd% = 3                  '    "
                              If action% = 20 Then escd% = 4                  '    "
                              If action% = 32 Then escd% = 5                  '    "
                              If action% = 34 Then escd% = 6                  '18Mar03 TH (PBSv4) Added
                              If action% = 35 Then                           '23Jul03 TH Added
                                 escd% = 0                                   '    "
                                 blnPBSSuppressExceptional = True            '    "
                              End If                                         '    "
                              PatientBilling escd%
                              blnPBSSuppressExceptional = False              '    "
                              m_strPBSLastDate = "" '06Mar03 TH (PBSv4) Added
''                              If Not escd% Then                     '31Jan03 TH (PBSv4) Added
''                                 PBSUpdateIssuePanel                '   "
''                                 'dispens.F3D1.Height = 200          '   "   '20Jun03 TH Replaced
''                                 dispens.F3D1.Height = 230                   '    "
''                                 PBSRefreshPatDetails dispens.F3D1  '   "
''                              End If                                '   "
                              Screen.MousePointer = STDCURSOR       '   "
                        End If
                 
            Else
               ' normal dispensing so clear all patient billing fields on the label
               '''ClearPatBillLbl
            End If
''         If billit Then                                                       '16Nov99 SF
''               repeats% = NumberOfRepeats%()
''               If fatalErr% Then GoTo PatBillExit
''               Select Case billingtype
''                  'Case 1:  '16Nov99 SF moved pharmac code into case statement   '14Jul00 SF replaced
''                  Case 1, 3:                                                     '14Jul00 SF added Repeat Dispensing
''                     If newDispensing% = True And ((repeats% <> -1 And l.batchnumber > (1 + repeats%)) Or (l.batchnumber = 0 And repeats% = 0)) Then
''                           ' issued all repeats allowed for this item
''                           ClearPatBillLbl
''                        Else
''                           PatientBilling escd%
''                        End If
''                  '16Nov99 SF added for PBS
''                  Case 2:
''                     'If newDispensing% = True And ((repeats% <> -1 And l.batchnumber > (1 + repeats%))) Then  '16Nov00 SF replaced
''                     'If (newDispensing% = True) And (repeats% <> -1) And (l.batchnumber > repeats) Then        '16Nov00 SF fixed logic that was allowing more repeats that specified
''                     If (newDispensing% = True) And (repeats% <> -1) And ((l.batchnumber > repeats) And repeats <> 0) Then '31Jan03 TH (PBSv4) Added
''                           ' issued all repeats allowed for this item
''                           ClearPatBillLbl
''                           escd = True    '16Nov00 SF added
''                        Else
''                              If newDispensing% Then m_intRepeatInterval = 0  '31Jan03 TH (PBSv4) Added
''                              If action% = 19 Then escd% = 3                  '    "
''                              If action% = 20 Then escd% = 4                  '    "
''                              If action% = 32 Then escd% = 5                  '    "
''                              If action% = 34 Then escd% = 6                  '18Mar03 TH (PBSv4) Added
''                              If action% = 35 Then                           '23Jul03 TH Added
''                                 escd% = 0                                   '    "
''                                 blnPBSSuppressExceptional = True            '    "
''                              End If                                         '    "
''                              PatientBilling escd%
''                              blnPBSSuppressExceptional = False              '    "
''                              m_strPBSLastDate = "" '06Mar03 TH (PBSv4) Added
''                              If Not escd% Then                     '31Jan03 TH (PBSv4) Added
''                                 PBSUpdateIssuePanel                '   "
''                                 'dispens.F3D1.Height = 200          '   "   '20Jun03 TH Replaced
''                                 dispens.F3D1.Height = 230                   '    "
''                                 PBSRefreshPatDetails dispens.F3D1  '   "
''                              End If                                '   "
''                              Screen.MousePointer = STDCURSOR       '   "
''                        End If
''                  '16Nov99 SF -----
''                  '**!! add additional billing types here
''               End Select
''            Else
''               ' normal dispensing so clear all patient billing fields on the label
''               ClearPatBillLbl
''            End If
''
''      Case 2:
''         'If billPat% = True And setUpOk% = True Then PatientBillingEnd       '17Dec99 SF replaced
''         'If (billPat% = True) And (setUpOk% = True) Then PatientBillingEnd    '17Dec99 SF
''         '28Apr03 TH (#67950) - if set up incorrect then some billing db objects could still be open ! Replaced above line
''         If (billPat% = True) Then
''            If (setUpOk% = True) Then
''               PatientBillingEnd
''            Else
''               On Error Resume Next
''               PatInfo.Close: Set PatInfo = Nothing
''               patfees.Close: Set patfees = Nothing
''               If foundDrugitem% Then snpDrug.Close: Set snpDrug = Nothing
''               foundDrugitem = False
''               Patdb.Close: Set Patdb = Nothing
''               m_strPBSLastDate = ""
''               On Error GoTo 0
''            End If
''         End If
         '---------------------------
      Case 3:
''         'If billPat% = True And setUpOk% = True And pid.status = "O" Then    '16Nov99 SF replaced
''         If billit Then                                                       '16Nov99 SF
''               repeats% = NumberOfRepeats%()
''               If fatalErr% Then GoTo PatBillExit
''               If NumberOfOwes!(0) = 0 And ((repeats% <> -1 And l.batchnumber > repeats%) Or (l.batchnumber = 0 And repeats% = 0)) Then
''                     popmessagecr "#ASCribe Patient Billing", "You have reached the maximum number of dispensings for this item." & cr & "If you continue the issue you will not be able to charge the patient."
''                  End If
''            End If
''
      Case 4:
''         'If billPat% = True And setUpOk% = True And pid.status = "O" Then    '16Nov99 SF replaced
''         If billit Then                                                       '16Nov99 SF
''               If toDispens! > 0 Then
''               Qty! = toDispens!
''                  '10Aug05 TH Added
''                  If Val(d.convfact) <> 0 Then   '29Jul98 ASC
''                        numlabels = Qty! \ Val(d.convfact)
''                        If Qty! Mod Val(d.convfact) > 0 Then numlabels = numlabels + 1
''                        ReDim LabelValues!(numlabels)
''                        For intLoop = 1 To Qty! \ Val(d.convfact)
''                           LabelValues!(intLoop) = Val(d.convfact)
''                        Next
''                        If Qty! Mod Val(d.convfact) <> 0 Then LabelValues!(numlabels) = Qty! - (Val(d.convfact) * (Qty! \ Val(d.convfact)))  'NB Cannot use MOD as this converts to integers!!
''                        txtReturn$ = Format$(numlabels)
''                     End If
''                  '-------------
''               End If
''            End If

      Case 5:
         popmessagecr "EMIS Health", "Attempting to reuse label in billing"
         'If billPat% = True And setUpOk% = True And pid.status = "O" Then     '16Nov99 SF replace
''         If billit Then                                                        '16Nov99 SF
''               '16Nov99 SF added case statement to allow PBS to lookup on prescriptionid
''               Select Case billingtype
''                  '*16May00 SF now uses l.prescriptionid for both PBS and Pharmac
''                  'Case 1:
''                  '   sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
''                  'Case 2
''                  Case 1, 2:
''                  '*16May00 SF -----
''                     sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(l.prescriptionid) & ";"
''               End Select
''               '16Nov00 SF added to create new rx# and reset the number of repeats been used
''               GetPointer patdatapath$ + "\RxID.dat", l.prescriptionid, True
''               l.batchnumber = 0
''               '16Nov00 SF -----
''               WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''               Patdb.Execute (sql$):  DoSaferEvents 1
''            End If

      Case 6:
''         'If billPat% = True And setUpOk% = True And pid.status = "O" Then     '16Nov99 SF replaced
''         If billit Then                                                        '16Nov99 SF
''               repeats% = NumberOfRepeats%()
''               If fatalErr% Then GoTo PatBillExit
''               If NumberOfOwes!(0) = 0 And (l.batchnumber = 0 Or l.batchnumber > repeats%) Then
''                     If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "Y", "DiscontinueAfterLastRepeat", 0)) Then
''                           SaveLabel False, 0
''                           DiscontinueItem
''                        End If
''                  End If
''            End If
      
      Case 7:
'''         'If billPat% = True And setUpOk% = True And pid.status = "O" Then txtReturn$ = txtReturn$ & "/" & Format$(l.batchnumber)      '16Nov99 SF replaced
'''         'If billIt And BillingType = 1 Then txtReturn$ = Format$(labf&) & "/" & Format$(l.batchnumber)                                '16Nov99 SF '17Dec99 SF replaced
'''         'If (billIt) And (BillingType = 1) Then txtReturn$ = Format$(labf&) & "/" & Format$(l.batchnumber)                             '17Dec99 SF '*16May00 SF replaced
'''         'If (billIt) And (billingType = 1) Then txtReturn$ = Format$(l.prescriptionid) & "/" & Format$(l.batchnumber)                   '*16May00 SF now uses l.prescriptionID as the rx#   '14Jul00 SF replaced
'''         If (billit) And ((billingtype = 1) Or (billingtype = 3)) Then txtReturn$ = Format$(l.prescriptionid) & "/" & Format$(l.batchnumber)                                                 '14Jul00 SF added for Repeat Dispensing
'''         '16Nov00 SF added additional information to be displayed
         If billit And (intBillingtype = 2) Then
               '01Jun07 TH If L.IssType <> "C" Then txtReturn$ = Trim$(txtReturn$) & "/" & Format$(L.batchnumber)
               If L.IssType <> "C" Then txtReturn$ = Trim$(txtReturn$) & "/" & Format$(m_PBSDrugRepeat.NumberOfIssues)
               ItemTypeStatus False, "", "", "", ""    '31Jan03 TH (PBSv4) Added extra params
               If PBSItemType$ = "N" Then
                     txtReturn$ = txtReturn$ & " (Private)"
                  Else
                     Select Case PBSItemStatus$
                        Case "O": txtReturn$ = txtReturn$ & " (Rx Owing)"
                        Case "D": txtReturn$ = txtReturn$ & " (Item Deferred)"
                        Case "U": txtReturn$ = txtReturn$ & " (Unoriginal Supply)"
                        Case "R": txtReturn$ = txtReturn$ & " (Regulation 24)"
                        Case Else: txtReturn$ = txtReturn$ & " (PBS)"
                     End Select
                  End If
            End If
'''         '16Nov00 SF -----
      Case 8:
'''         'If billPat% = True And setUpOk% = True And pid.status = "O" Then    '16Nov99 SF replaced
'''         If billit Then                                                       '16Nov99 SF
'''
'''               Select Case billingtype%
'''                  'Case 1    'Pharmac              '16Nov99 SF replaced
'''                  'Case 1, 2:    'Pharmac, PBS      '16Nov99 SF      '14Jul00 SF replaced
'''                  Case 1, 2, 3:                                      '14Jul00 SF incorporated Repeat Dispensing
'''                     repeats% = NumberOfRepeats%()
'''                     If repeats% = -1 Then
'''                           txtReturn$ = txtReturn$ & cr & "Number of repeats:" & TB & "Completed / not specified yet" & cr
'''                           txtReturn$ = txtReturn$ & "Qty dispensed so far:" & TB & "0" & cr
'''                           txtReturn$ = txtReturn$ & "Total dispensing qty:" & TB & "Completed / cannot be calculated yet" & cr
'''                        Else
'''                           txtReturn$ = txtReturn$ & cr & "Number of repeats:" & TB & Format$(repeats%) & cr
'''                           txtReturn$ = txtReturn$ & "Qty dispensed so far:" & TB
'''                           Owed! = NumberOfOwes!(origDispens!)
'''                           'If billingType = 1 Then    '16Nov99 SF added     '14Jul00 SF replaced
'''                           '16Nov00 SF split up Pharmac and Repeat Dispensing to deal with Pharmac variable qtys
'''                           'If (BillingType = 1) Or (BillingType = 3) Then   '14Jul00 SF incorporated Repeat Dispensing
'''                           If billingtype = 1 Then
'''                                  QtyDispensed Value!, totalValue!
'''                              ElseIf billingtype = 3 Then
'''                                 '16Nov99 SF moved into the above IF block
'''                                 If l.batchnumber = 0 Then
'''                                       Value! = origDispens! - Owed!
'''                                    Else
'''                                       Value! = (l.batchnumber * origDispens!) - Owed!
'''                                    End If
'''                              '16Nov99 SF added for PBS
'''                              ElseIf billingtype = 2 Then
'''                                 ItemTypeStatus False, "", "", ""     '31Jan03 TH (PBSv4) Added extra params
'''                                 If PBSItemType$ = "D" Then
'''                                       Value! = 0
'''                                    Else
'''                                       Value! = (l.batchnumber * origDispens!)
'''                                    End If
'''                              End If
'''                              '16Nov99 SF -----
'''                           txtReturn$ = txtReturn$ & Format$(Value!) & " " & LCase$(Trim$(d.PrintformV)) & cr    '08Mar03 TH/ATW added $ on lcase
'''                           txtReturn$ = txtReturn$ & "Total dispensing qty:" & TB
'''                           '16Nov00 SF now deals with Pharmac variable qtys
'''                           If billingtype = 1 Then
'''                                txtReturn$ = txtReturn$ & Format$(totalValue!) & " " & LCase$(Trim$(d.PrintformV)) & cr  '08Mar03 TH/ATW added $ on lcase
'''                             Else
'''                                '16Nov00 SF does as before
'''                                Value! = (1 + repeats%) * origDispens!
'''                                txtReturn$ = txtReturn$ & Format$(Value!) & " " & LCase$(Trim$(d.PrintformV)) & cr  '08Mar03 TH/ATW added $ on lcase
'''                             End If
'''                           '16Nov00 SF -----
'''                        End If
'''                        '10Oct99 SF added
'''                        If billingtype = 1 Then
'''                              On Error Resume Next
'''                              '16Nov00 SF information now stored in the PatID.MDB
'''                              'sql$ = "SELECT * FROM patientinformation WHERE patientinformation.patrecno ='" & pid.recno & "';"
'''                              'Set snap = PatDB.CreateSnapshot(sql$)
'''                              sql$ = "SELECT * FROM PatBilling WHERE PatBilling.patrecno ='" & pid.recno & "';"
'''                              Set snap = Patdb.CreateSnapshot(sql$)
'''                              '16Nov00 SF -----
'''                              If Not snap.EOF Then txtReturn$ = txtReturn$ & "Current Safety Net:" & TB & Format$(GetField(snap!DispensedSinceFeb)) & " items" & cr
'''                              snap.Close: Set snap = Nothing
'''                              On Error GoTo 0
'''                           End If
'''                        '10Oct99 SF -----
'''                     '16Nov99 SF added
'''                     If billingtype = 2 Then
'''                           'sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber = " & Format$(labf&) & ";"
'''                           ''sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber = " & Format$(l.prescriptionid) & ";"
'''                           ''Set snap = Patdb.CreateSnapshot(sql$)
'''                           ''If Not snap.EOF Then txtReturn$ = txtReturn$ & "Authority Number:" & tb & Trim$(getfield(snap!specialAuthorityNum)) & cr
'''                           ItemTypeStatus False, "", strAuthNum, strOrigNum    '31Jan03 TH (PBSv4) Added params and used these rather than open new recordset
'''                           If Trim$(strAuthNum) <> "" Then txtReturn$ = txtReturn$ & "Authority Number:" & TB & Trim$(strAuthNum) & cr
'''                           Select Case PBSItemType$
'''                              Case "P": txtReturn$ = txtReturn$ & "Type:" & TB & "PBS" & cr
'''                              Case "N": txtReturn$ = txtReturn$ & "Type:" & TB & "Private" & cr
'''                           End Select
'''                           Select Case PBSItemStatus$
'''                              Case "D": txtReturn$ = txtReturn$ & "Status:" & TB & "Item was deferred" & cr
'''                              Case "O": txtReturn$ = txtReturn$ & "Status:" & TB & "Emergency Dispense (Rx owed)" & cr
'''                              Case "R": txtReturn$ = txtReturn$ & "Status:" & TB & "Regulation 24" & cr
'''                              Case Else:
'''                                 'If Not snap.EOF Then                                              '31Jan03 TH (PBSv4) Removed
'''                                       'If Trim$(getfield(snap!originalapprovalnumber)) = "" Then   '31Jan03 TH (PBSv4) Replaced
'''                                       If Trim$(strOrigNum) = "" Then                               '   "
'''                                             txtReturn$ = txtReturn$ & "Status:" & TB & "Normal Dispensing" & cr
'''                                          Else
'''                                             txtReturn$ = txtReturn$ & "Status:" & TB & "Normal Dispensing (Unoriginal)" & cr
'''                                          End If
'''                                 '   End If
'''                           End Select
'''                           'snap.Close : Set snap = Nothing      '31Jan03 TH (PBSv4) Removed
'''                        End If
'''                     '16Nov99 SF -----
'''
'''                  ' !!** put additional billing types here
'''               End Select
'''            End If

      '16Nov99 SF added for PBS to setup the default issue qty
      Case 9:
         If (billit) And isPBS() Then
            ExceptionalPricing True, 0         '31Jan03 TH (PBSv4) Ensure Exceptional price is 0
            If txtReturn$ = "1" Then      ' for an issue
               Qty! = 0             '19Nov99 SF added as we will not be using the qty calculated but that in the issue box
                                    '           was causing qty calculated to be added to qty accepted in the issue box
               m_strPBSLastDate = LastSavedDateTimeToDateTime(L.lastSavedDateTime) ' 40210 XN 15Feb13 use proper date\time for WLabel   L.lastdate  '03Mar03 TH (PBSv4) Added to retain for the repeat check
               SaveLabel 0    '18Nov99 SF moved from above to force savelabel so l.prescriptionid is created which needs to be recorded on PBS docs
               dispensStatus$ = ""
               OriginalDate$ = ""
               OriginalApprovalNumber$ = ""
               OriginalScriptNumber$ = ""
               '01Jun07 TH If L.batchnumber = 0 Then                 '16Nov00 SF added to only check on a new drug entry (an original dispensing)
               If m_PBSDrugRepeat.NumberOfIssues = 0 Then
                  'myErr = 0                                 '16Nov00 SF added
                  'On Error Resume Next                      '16Nov00 SF added
                  valid = Len(Trim$(asciiz(m_PBSProduct.PBScode))) > 0                  '16Nov00 SF added
                  'myErr = Err                               '16Nov00 SF added
                  'On Error GoTo PatBillErr                  '16Nov00 SF added
                  'If myErr = 91 Then                        '16Nov00 SF added, get round object not set error. ie. when an item is saved but not issued and then attempt an issue when re-entering the pmr
                  '   If L.Nodissued = 0 Then               '16Nov00 SF added
                  '      If d.hasformula = "Y" Then    '16Nov00 SF added
                  '          AttachManuPBScode foundDrugitem           '16Nov00 SF added
                  '      Else
                  '         If escd Then foundDrugitem = False  ''31Jan03 TH (PBSv4) Added   '     "
                  '      End If
                  '   Else                             '16Nov00 SF added
                  '       GoTo PatBillErr              '16Nov00 SF added
                  '   End If                           '16Nov00 SF added
                  'End If '0Jun07 TH removed
                  If valid Then                    '16Nov00 SF added
                     foundDrugitem = True
                     'EPitem = False         '16Nov00 SF removed
                  Else
                     foundDrugitem = False
                   '  snpDrug.Close: Set snpDrug = Nothing
                  End If
               End If '03Jun07 Th Added
               On Error GoTo PatBillErr   '16Nov00 SF added
            End If                              '16Nov00 SF added
                     
            'If (foundDrugitem = True Or EPItem = True) And L.batchnumber = 0 Then '01Jun07 Th
            If (foundDrugitem = True Or EPItem = True) And m_PBSDrugRepeat.NumberOfIssues = 0 Then
            
               ' original and PBS drug so default to PBS max qty
               FrmIssue.Caption = Trim$(FrmIssue.Caption) & " (PBS Max Qty)"
               '31Jan03 TH (PBSv4) Check here for reg 24 issue and multiple qty by all repeats if this applies.
               If Billitems$(53) = "R" Then                                                   '31Jan03 TH (PBSv4)
                  txtReturn$ = Format$((m_PBSProduct.maxqty) * (Val(Billitems$(11)) + 1))  '   "
               Else                                                                           '   "
                  txtReturn$ = Format$(m_PBSProduct.maxqty)
               End If                                                                         '   "
               If EPItem Then                                                                                                                                                          '31Jan03 TH (PBSv4) Factor the packsize as this will be in issue units?
                  If Trim$(UCase$(Format$(m_PBSProduct.IssueUnit))) <> Trim$(UCase$(d.PrintformV)) And d.mlsperpack > 0 Then txtReturn$ = Format$(Val(txtReturn$) / d.mlsperpack) '    "
               End If                                                                                                                                                                  '    "
               FrmIssue.TxtIssue.Text = txtReturn$
               Qty! = Val(txtReturn$)
            ElseIf m_PBSDrugRepeat.NumberOfIssues > 0 Then
               ' a repeat so deafult to the repeat qty (all repeats must be of the original qty)
               ItemTypeStatus False, "", "", "", txtReturn$ '17Sep01 TH %PBS% Added parameter   '31Jan03 TH (PBSv4) Added Extra params
               '''sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
               '''Set snap = Patdb.CreateSnapshot(sql$)
               '''If Not snap.EOF Then
               If Not (txtReturn$) = "" Then 'Signifies there is a repeat record
''                     specialauthoritynum$ = Trim$(GetField(snap!specialauthoritynum))
''                     txtReturn$ = Format$(GetField(snap!DispensQty))
''                     originaldate$ = Trim$(GetField(snap!originaldate))
''                     originalapprovalnumber$ = Trim$(GetField(snap!originalapprovalnumber))
''                     originalscriptnumber$ = Trim$(GetField(snap!originalscriptnumber))
                  '16Nov00 SF added to get codes from the previous dispensing and lookup original selection
''                     PBSCode$ = Trim$(GetField(snap!PBSCode))
''                     manuCode$ = Trim$(GetField(snap!ManufacturersCode))
''                     If d.hasformula = "Y" Then
''                        sql$ = "SELECT * FROM epaverageprices WHERE pbscode = '" & PBSCode$ & "';"
''                        EPItem = True
''                     Else
''                        sql$ = "SELECT * FROM pbsdrugs WHERE nsvcode = '" & d.SisCode & "' AND pbscode = '" & PBSCode$ & "' AND manufacturerscode = '" & manuCode$ & "';"
''                        EPItem = False
''                     End If
''                     If Trim$(PBSCode) <> "" And Not EPItem Then       '31Jan03 TH (PBSv4) ignore also EP Items
''                        Set snpDrug = Patdb.CreateSnapshot(sql$)
''                        If snpDrug.EOF Then
''                           '**!! should never happen
''                           escd = True
''                           If L.batchnumber = 0 Then popmessagecr "#ASCribe Patient Billing", "Cannot find the item information in the PBS table" & cr & "Cannot bill on this item."
''                        Else
''                           foundDrugitem = True
''                        End If
''                     Else
''                         foundDrugitem = False
''                     End If
               Else
                  '**!! should never happen
                  'Just Did - Reason = previously nonPBS issue being issued now on repeat as PBS without PBSCode or any historical data
                  escd = True
                  popmessagecr "#Patient Billing", "Cannot find drug repeat information" & cr & "Cannot bill on this item."
                  billpatient = True  'escape  '19Mar03 TH (PBSv4) added (#67233)
                  GoTo PatBillExit             '   "
               End If
               '03Jun07 TH Replaced
               'FrmIssue.TxtIssue.Text = txtReturn$    ' put qty in issue box
               FrmIssue.TxtIssue.Text = m_PBSDrugRepeat.DispensQty
               'Qty! = Val(txtReturn$)                 ' set qty in has it has been changed
               Qty! = m_PBSDrugRepeat.DispensQty
               '-------------------
               
               '''If Trim$(GetField(snap!status)) = "P" Then FrmIssue.Caption = Trim$(FrmIssue.Caption) & " (PBS Max Qty)"
               If Trim$(PBSItemStatus$) = "P" Then FrmIssue.Caption = Trim$(FrmIssue.Caption) & " (PBS Max Qty)"
''                  snap.Close: Set snap = Nothing
            Else     ' for a return
               ' default qty to return
               'MsgBox "get default qty here !!!!"
   ''               sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
   ''               Set snap = Patdb.CreateSnapshot(sql$)
   ''               If Not snap.EOF Then
   ''                  txtReturn$ = Format$(GetField(snap!DispensQty))
   ''               Else
   ''                  txtReturn$ = ""
   ''               End If
   ''               snap.Close: Set snap = Nothing
               If m_PBSDrugRepeat.PBSDrugRepeatID > 0 Then
                  txtReturn$ = Format$(m_PBSDrugRepeat.DispensQty)
               Else
                  txtReturn$ = ""
               End If
            End If
         End If


      ' ensure if PBS max qty overwritten then it is a special authority or private prescription
      Case 10:
         'If (billIt = True) And BillingType = 2 Then    '17Dec99 SF replaced
         If (billit) Then          '17Dec99 SF
            '01Jun07 TH If L.batchnumber = 0 Then
            If m_PBSDrugRepeat.NumberOfIssues = 0 Then
               ' on original dispensing ensure if qty > pbs max then it is special authority or a private prescription
               escd = False
               '16Nov00 SF added the following to deal with EP items
               If (EPItem) And (foundDrugitem) Then
                  ' set number of repeats
                  'drugrepeats = getfield(snpDrug!maxrepeats)   '19Mar03 TH (PBSv4) Replaced
                  drugrepeats = Val(Billitems$(11))             '     "
                  'check to see if issue over max, if it is then get authority number or a private prescription
                  If Val(txtReturn$) > m_PBSProduct.maxqty Then
                     valid = True
                     Do
                        strAns = ""
                        k.nums = True
                        inputwin "Patient Billing", txtReturn$ & " " & Trim$(d.PrintformV) & " is above the PBS Max Qty of " & Format$(m_PBSProduct.maxqty) & " " & Trim$(d.PrintformV) & " for this item" & cr & "To prescribe more a special authority is required or the" & cr & "prescription must be private." & cr & cr & "Enter authority number to continue" & cr & "or leave blank for a private prescription.", strAns, k
                        If k.escd Then
                           escd = True
                        Else
                           Qty! = Val(txtReturn$)
                           If Trim$(strAns) <> "" Then
                              ValidateCardNumber strAns, "A", valid
                              If valid Then
                                 ' special authority granted
                                 SpecialAuthorityNum$ = strAns
                                 PBSItemType$ = "P"
                              End If
                           Else
                              ' private prescription
                              PBSItemType$ = "N"
                           End If
                        End If
                     'Loop Until valid                '16Nov00 SF replaced
                     Loop Until (valid) Or (escd)     '16Nov00 SF now allows cancelling out
                  Else
                     ' qty within range so a PBS prescription
                     Qty! = Val(txtReturn$)
                     PBSItemType$ = "P"

                  End If
               ElseIf (Not foundDrugitem) And (Not EPItem) Then      '16Nov00 SF
                  ' not found in PBS schedule so default to a private prescription
                  PBSItemType$ = "N"
                  drugrepeats = Val(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "0", "PrivateRxNumRpts", 0))      ' default a value user can override later
                  Qty! = Val(txtReturn$)     '02Dec99 SF to set qty! if modified in issue box
               Else
                  'drugrepeats = getfield(snpDrug!MaxRepeats) '31Jan03 TH (PBSv4) Replaced
                  If m_PBSDrugRepeat.NumberOfIssues = 0 Then   '03Jun07 TH
                     drugrepeats = m_PBSProduct.MaxRepeats        '03Jun07 TH
                  Else                                         '03Jun07 TH
                     drugrepeats = Val(Billitems$(11))           '    "
                  End If                                       '03Jun07 TH
                  restriction$ = ""
                  If foundDrugitem Then restriction$ = UCase$(Trim$(m_PBSProduct.RestrictionFlag))
                  If restriction$ = "A" Then    ' checks for an authority drug
                     Qty! = Val(txtReturn$)   '31Jan03 TH (PBSv4) Keep this
                  Else     ' checks for an non-authority drug
                     If Val(txtReturn$) > m_PBSProduct.maxqty And (Trim$(UCase$(Billitems$(53))) <> "R" Or Val(txtReturn$) > (Val(Billitems$(11)) + 1) * m_PBSProduct.maxqty) Then '    "              reg 24 issues !
                        valid = True
                        If Billitems$(53) <> "X" Then     '01Apr03 TH Replaced
                           Do
                              strAns = ""
                              k.nums = True
                              inputwin "Patient Billing", txtReturn$ & " " & Trim$(d.PrintformV) & " is above the PBS Max Qty of " & Format$(m_PBSProduct.maxqty) & " " & Trim$(d.PrintformV) & " for this item" & cr & "To prescribe more a special authority is required or the" & cr & "prescription must be private." & cr & cr & "Enter authority number to continue" & cr & "or leave blank for a private prescription.", strAns, k
                              If k.escd Then
                                 escd = True
                              Else
                                 Qty! = Val(txtReturn$)
                                 If Trim$(strAns) <> "" Then
                                    ValidateCardNumber strAns, "A", valid
                                    If valid Then
                                       ' special authority granted
                                       SpecialAuthorityNum$ = strAns
                                       PBSItemType$ = "P"
                                    End If
                                 Else
                                    ' private prescription
                                    PBSItemType$ = "N"
                                 End If
                              End If
                           Loop Until (valid) Or (escd)     '16Nov00 SF now allows cancelling out
                        End If                          '31Mar03 TH (PBSv4)
                     Else
                        ' qty within range so a PBS prescription
                        Qty! = Val(txtReturn$)
                        PBSItemType$ = "P"
                     End If
                  End If
               End If
               If Not escd Then
                  ' write repeat and status info
                  If Trim$(PBSItemStatus$) = "" Then PBSItemStatus$ = "N"     '31Jan03 TH (PBSv4) Only set to default if not previously set
               
                     '''''TH ***99PBS*** Set objBilling = CreateObject(m_strBillingComponent)
                     'lngCount = objBilling.PBSDrugRepeatCountbyPatrecnoAndPrescritionID(g_SessionID, 1, d.SisCode, minsToday&)
                     '''''lngCount = objBilling.NumberOfRepeats(g_SessionID, gRequestID_Prescription)
                     '''''Set objBilling = Nothing
                     
'''                  sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
'''                  Set dyn = Patdb.CreateDynaset(sql$)
                     ''Update the type
                     m_PBSDrugRepeat.RequestID = gRequestID_Prescription
                     m_PBSDrugRepeat.DrugID = d.DrugID
                     
                     If m_PBSDrugRepeat.NumberOfRepeats <> -1 Then  'Update
'''                     dyn.Edit
'''                     dyn!NumberOfRepeats = drugrepeats
'''                     dyn!DispensQty = Val(txtReturn$)
'''                     dyn!specialauthoritynum = specialauthoritynum$
'''                     dyn!originaldate = Billitems$(59)
'''                     dyn.Update
                        m_PBSDrugRepeat.NumberOfRepeats = drugrepeats
                        m_PBSDrugRepeat.DispensQty = Val(txtReturn$)
                        m_PBSDrugRepeat.SpecialAuthorityNum = SpecialAuthorityNum$
                        m_PBSDrugRepeat.OriginalDate = Billitems$(59)
'''                     dyn.Close: Set dyn = Nothing
                        '''''TH ***99PBS***Set objBilling = CreateObject(m_strBillingComponent)
                        'lngOK = objBilling.PBSDrugRepeatLimitedUpdatebyPatrecnoAndPrescritionID(g_SessionID, Val(pid.recno), L.prescriptionid, drugrepeats, Val(txtReturn$), specialauthoritynum$, Billitems$(59))
                        'Set objBilling = Nothing
                        '''''-------------------
                        
                     Else  'Insert
'''                     dyn.Close: Set dyn = Nothing
'''                  '-----------------------------------------
'''                     sql$ = "INSERT INTO drugrepeats (patrecno, rxnumber, numberofrepeats, dispensqty, specialauthoritynum, pbscode, manufacturerscode, solventcode,originaldate) VALUES ('" & pid.recno & "' , " & Format$(L.prescriptionid) & " , " & drugrepeats & " , " & Val(txtReturn$) & " , '" & specialauthoritynum$ & "', '" & PBSCode$ & "', '" & manuCode$ & "', '" & solventPBScode$ & "', '" & Billitems$(59) & "');"  '25Feb03 TH (PBSv4) Added write of original rx date from billitems array
'''                     WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
'''                     Patdb.Execute (sql$): DoSaferEvents 1
                        '''''TH ***99PBS***Set objBilling = CreateObject(m_strBillingComponentWrite)
                        'lngOK = objBilling.DrugRepeatInsert(g_SessionID, Val(pid.recno), L.prescriptionid, drugrepeats, Val(txtReturn$), 0, "", "", "", specialauthoritynum$, Billitems$(59), "", "", PBSCode$, manuCode$, solventPBScode$, 0, 0, "", 0, "", 0, "", "", "", gRequestID_Prescription)
                        'Set objBilling = Nothing
                        '''''--------------------
                        m_PBSDrugRepeat.PatRecNo = pid.recno
                        m_PBSDrugRepeat.RxNumber = Format$(L.prescriptionid)
                        m_PBSDrugRepeat.NumberOfRepeats = drugrepeats
                        m_PBSDrugRepeat.DispensQty = Val(txtReturn$)
                        m_PBSDrugRepeat.SpecialAuthorityNum = SpecialAuthorityNum$
                        m_PBSDrugRepeat.PBScode = PBScode$
                        m_PBSDrugRepeat.ManufacturersCode = manuCode$
                        m_PBSDrugRepeat.SolventCode = solventPBScode$
                        m_PBSDrugRepeat.OriginalDate = Billitems$(59)
                        
                     End If   '17Mar03 TH (PBSv4)
                     PBSDrugRepeatWrite
               End If
            Else
               ' ensure repeats are of the same qty
               'sql$ = "SELECT drugrepeats.dispensqty FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
'''               sql$ = "SELECT drugrepeats.dispensqty FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
'''               Set snap = Patdb.CreateSnapshot(sql$)
'''               If Val(txtReturn$) <> GetField(snap!DispensQty) Then
'''                  popmessagecr "#ASCribe Patient Billing", "Repeats must be of the same quantity" & cr & "The quantity will be reset to " & Format$(GetField(snap!DispensQty)) & " " & Trim$(d.PrintformV)
'''                  Qty! = GetField(snap!DispensQty)
'''               End If
'''               snap.Close: Set snap = Nothing

            End If

            ' need to check if deferred

            If Not escd Then
'''               sql$ = "SELECT drugrepeats.status FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
'''               Set snap = Patdb.CreateSnapshot(sql$)
'''               If Not snap.EOF Then
'''                  If Trim$(GetField(snap!status)) = "D" Then
'''                     dispensStatus$ = "D"
'''                     PBSItemStatus$ = "N"
'''                  End If
'''               Else
'''                  '**!! should never happen
'''               End If
'''               snap.Close: Set snap = Nothing
            End If
         '23Jan01 SF added to update variable qtys if changed on the issue screen
         
         '23Jan01 SF -----
         End If
      
      
      Case 11:
         'If truefalse(TxTd(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0)) And Val(TxTd(patdatapath$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0)) = 2 Then        '17Dec99 SF relaced
         If (TrueFalse(TxtD(dispdata$ & "\PATMED.INI", "PatientBilling", "N", "BillPatient", 0))) And (Val(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0)) = 2) Then     '17Dec99 SF
               intBillingtype = Val(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0))  '18Nov99 SF have to set billing type as not been through PatientBillingSetup: yet
               If ItemForBilling() Then   '18Nov99 SF added to only get original date of prescription on PBS dispensing
                     k.Max = 11
                     datePrescriptionWritten$ = ""
                     If Trim$(OriginalDate$) = "" Then        '31Jan03 TH (PBSv4)
                        strAns = Format$(Now, "dd/mm/yyyy")
                     Else                                     '  "
                        strAns = OriginalDate$                  '  "
                     End If                                   '  "
                     txt$ = "Please enter the date the prescription was written"
                     Do
                        inputwin "Patient Billing", txt$, strAns, k
                        If Not k.escd Then
                              parsedate strAns, Out$, "1", valid
                              If Not valid Then
                                    BadDate     '16Nov00 SF added
                                    txt$ = "The date entered was not valid" & cr & "Please enter the date the prescription was written"
                                 Else
                                    '16Nov00 SF added to confirm the date
                                    If strAns <> Out$ Then
                                          strAns = Out$
                                          txt$ = "Confirm date the prescription was written"
                                          inputwin "Patient Billing", txt$, strAns, k
                                          parsedate strAns, Out$, "1", valid
                                       End If

                                    ' check to make sure date entered is not in the future, if it is then warn the user
                                    If Val(Right$(Out$, 4) & Mid$(Out$, 4, 2) & Left$(Out$, 2)) > Val(Format$(Now, "yyyymmdd")) Then
                                             If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "AllowFutureOriginalDate", 0)) Then         '31Jan03 TH (PBSv4)
                                          txt$ = "The date entered is in the future." & cr & "Do you want to continue with this date?"
                                          strAns = "N"
                                          askwin "?Patient Billing", txt$, strAns, k
                                          If (strAns = "N") Or k.escd Then
                                                         valid = False                                                                           '31Jan03 TH (PBSv4)
                                                         k.escd = True                                                                           '   "
                                                      End If                                                                                     '   "
                                                Else                                                                                             '   "
                                                   txt$ = "A Date in the Future is invalid"                                                      '   "
                                                   popmessagecr "!Patient Billing", txt$                                                 '   "
                                                valid = False
                                                k.escd = True
                                             End If
                                       End If

                                    '16Nov00 SF -----
                                    If Not k.escd Then      '16Nov00 SF added to check if user cancelled
                                          datetodays Out$, Format$(Now, "dd/mm/yyyy"), numDays&, 0, "", 0
                                          If numDays& <= 365 Then
                                                datePrescriptionWritten$ = Out$
                                             Else
                                                txt$ = "The prescription has expired. A prescription is only valid for 12 months"
                                             End If
                                       End If               '16Nov00 SF added
                                 End If
                           End If
                     Loop Until Trim$(datePrescriptionWritten$) <> "" Or (k.escd)
                     If Not k.escd Then OriginalDate$ = datePrescriptionWritten$  '31Jan03 TH (PBSv4)
                     escd = k.escd
                  End If                  '18Nov99 SF
            End If
         
      ' The same item should not be prescribed twice in the same day for the same patient
      ' Here we have d.siscode in reference - we compare this with siscodes on all current labels
      
      Case 12:
      
         StringToDate Format$(Now, "dd/mm/yyyy"), DT1
         datetomins DT1
         minsToday& = DT1.mint

      
''         strParams = gTransport.CreateInputParameterXML("Currrent", trnDataTypeBit, 1, 1) & _
''                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
''                     gTransport.CreateInputParameterXML("minsToday", trnDataTypeint, 1, minsToday&)
''
''         lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLabelsbyEpisodeandSiscodeandDate", strParams)
         '''''TH ***99PBS***Set objBilling = CreateObject(m_strBillingComponent)
         'blnAlreadyPrescribed = objBilling.Regulation24CheckbyNSVCode(g_SessionID, 1, d.SisCode, minsToday&)
         'Set objBilling = Nothing
         '''''TH ***99PBS***
         If blnAlreadyPrescribed Then
            askwin "?Patient Billing", "This drug should not be prescribed twice on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", strAns, k   '02Dec99 SF expanded the warning
            If strAns = "N" Or k.escd Then
               escd = True
            End If
         End If
                  '24Jun03 TH Added Section ------
         If Not escd And TrueFalse(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "N", "PBSDuplicateCodeCheck", 0)) Then
               'Check now the PBSCodes of the items in question
               'SQL$ = "Select * from transactions where  patrecno = '" & Trim$(pid.recno) & "' and format(transdate,'dd/mm/yyyy') = format(now,'dd/mm/yyyy') and pbscode ='" & pbscode$ & "'"
               'Set snapcheck = Patdb.CreateSnapshot(SQL$)
'''               strParams = gTransport.CreateInputParameterXML("Currrent", trnDataTypeBit, 1, 1) & _
'''                           gTransport.CreateInputParameterXML("PBSCode", trnDataTypeVarChar, 5, PBSCode$)
'''
'''               lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "", strParams)
               '''''TH ***99PBS***Set objBilling = CreateObject(m_strBillingComponent)
               'blnAlreadyPrescribed = objBilling.Regulation24CheckbyNSVCode(g_SessionID, d.SisCode, Now)
               'Set objBilling = Nothing
               '''''TH ***99PBS***-----
               If blnAlreadyPrescribed Then
               'If lngCount > 0 Then
                     '''strDescription = GetField(snapcheck!Description)
                     askwin "?Patient Billing", "This drug should not be prescribed with " & strDescription & " (PBSCode:" & PBScode$ & ")" & cr & "on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", strAns, k  '02Dec99 SF expanded the warning
                     If strAns = "N" Or k.escd Then
                        escd = True
                     'Else
                     '   labf& = tmpLabf&
                     End If
                     L.SisCode = ""
                  End If
               'snapcheck.Close
               'Set snapcheck = Nothing
             End If
         '---------------------------
''         StringToDate Format$(Now, "dd/mm/yyyy"), DT1
''         datetomins DT1
''         minsToday& = DT1.mint
''
''
''         strParams = gTransport.CreateInputParameterXML("Currrent", trnDataTypeBit, 1, 1) & _
''                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
''                     gTransport.CreateInputParameterXML("minsToday", trnDataTypeint, 1, minsToday&)
''
''         lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLabelsbyEpisodeandSiscodeandDate", strParams)
''         If lngCount > 0 Then
''            askwin "?ASCribe Patient Billing", "This drug should not be prescribed twice on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", ans$, k   '02Dec99 SF expanded the warning
''            If ans$ = "N" Or k.escd Then
''               escd = True
''            End If
''         End If
''                  '24Jun03 TH Added Section ------
''         If Not escd And TrueFalse(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "N", "PBSDuplicateCodeCheck", 0)) Then
''               'Check now the PBSCodes of the items in question
''               'SQL$ = "Select * from transactions where  patrecno = '" & Trim$(pid.recno) & "' and format(transdate,'dd/mm/yyyy') = format(now,'dd/mm/yyyy') and pbscode ='" & pbscode$ & "'"
''               'Set snapcheck = Patdb.CreateSnapshot(SQL$)
''               strParams = gTransport.CreateInputParameterXML("Currrent", trnDataTypeBit, 1, 1) & _
''                           gTransport.CreateInputParameterXML("PBSCode", trnDataTypeVarChar, 5, PBSCode$)
''
''               lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "", strParams)
''               If lngCount > 0 Then
''                     strDescription = GetField(snapcheck!Description)
''                     askwin "?ASCribe Patient Billing", "This drug should not be prescribed with " & strDescription & " (PBSCode:" & PBSCode$ & ")" & cr & "on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", ans$, k  '02Dec99 SF expanded the warning
''                     If ans$ = "N" Or k.escd Then
''                        escd = True
''                     'Else
''                     '   labf& = tmpLabf&
''                     End If
''                     L.SisCode = ""
''                  End If
''               'snapcheck.Close
''               'Set snapcheck = Nothing
''             End If
         '---------------------------

         
''         'If billIt And BillingType = 2 Then       '17Dec99 SF replaced
''         If (billit) And (billingtype = 2) Then    '17Dec99 SF
''               tmpLabf& = labf&
''               StringToDate Format$(Now, "dd/mm/yyyy"), dt1
''               datetomins dt1
''               minsToday& = dt1.mint
''
''               'For x = UBound(LstRX$) To 1 Step -1           '17Mar03 TH Replaced to allow to search on history items (in pmr only not logs)
''               For x = 1 To 50                                '    "
''                  If Abs(labrf&(x)) <> 0 Then                 '    "
''                        labf& = Abs(labrf&(x))                '    "
''                        getlabel False
''                        'If l.SisCode = d.SisCode And ((l.startdate - minsToday& >= 0) And (l.startdate - minsToday&) <= 1440) Then                          '31Jan03 TH (PBSv4) Replaced with below
''                        If l.SisCode = d.SisCode And ((l.startdate - minsToday& >= 0) And (l.startdate - minsToday&) <= 1440) And txtReturn$ <> "AMEND" Then
''                              ans$ = "N"
''                              'askwin "?ASCribe Patient Billing", "This drug should not be prescribed twice on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & cr & "Do you want to continue?", ans$, k    '02Dec99 SF replaced with a longer warning
''                              askwin "?ASCribe Patient Billing", "This drug should not be prescribed twice on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", ans$, k   '02Dec99 SF expanded the warning
''                              If ans$ = "N" Or k.escd Then
''                                    escd = True
''                                 Else
''                                    labf& = tmpLabf&
''                                 End If
''                              l.SisCode = ""
''                              Exit For
''                           ''ElseIf truefalse(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "PBSDuplicateCodeCheck", 0)) And ((l.startdate - minsToday& >= 0) And (l.startdate - minsToday&) <= 1440) And txtReturn$ <> "AMEND" Then    '24Jun03 TH Added
''                           ''Check now the PBSCodes of the items in question
''                           '' set snapcheck = Patdb.createsnapshot("Select * from transactions where  patrecno = '" & trim$(pid.recno ) & "'
''                           ''Patdb.Execute (sql$)
''                           End If
''                     End If
''               Next
''               '24Jun03 TH Added Section ------
''               If Trim$(l.SisCode) <> "" And TrueFalse(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "Y", "PBSDuplicateCodeCheck", 0)) Then
''                     'Check now the PBSCodes of the items in question
''                     sql$ = "Select * from transactions where  patrecno = '" & Trim$(pid.recno) & "' and format(transdate,'dd/mm/yyyy') = format(now,'dd/mm/yyyy') and pbscode ='" & pbscode$ & "'"
''                     Set snapcheck = Patdb.CreateSnapshot(sql$)
''                     If Not snapcheck.EOF Then
''                           strDescription = GetField(snapcheck!Description)
''                           askwin "?ASCribe Patient Billing", "This drug should not be prescribed with " & strDescription & " (PBSCode:" & pbscode$ & ")" & cr & "on the same day for the same patient." & cr & "If you do need to issue, stamp 'Immediate Supply Necessary' on the prescription." & cr & "This is only applicable to an ORIGINAL script and it's REPEATS" & cr & "and NOT for two ORIGINAL scripts." & cr & cr & "Do you want to continue?", ans$, k  '02Dec99 SF expanded the warning
''                           If ans$ = "N" Or k.escd Then
''                                 escd = True
''                              'Else
''                              '   labf& = tmpLabf&
''                              End If
''                           l.SisCode = ""
''                        End If
''                     snapcheck.Close
''                     Set snapcheck = Nothing
''                   End If
''               '---------------------------
''               l.SisCode = ""
''               l.prescriptionid = 0 '05Mar03 TH Added as this was filled from the last item in the array, and went on to be picked up in the rpt table
''            End If
      
      ' returns True/False whether PBS is setup
      Case 13:
         'If billIt And BillingType = 2 Then escd = True          '17Dec99 SF replaced
''         If (billit) And (billingtype = 2) Then escd = True       '17Dec99 SF

      ' deal with returns from PBS
      Case 14:
         'If billIt And BillingType = 2 Then       '17Dec99 SF replaced
''         If billit And billingtype = 2 Then        '17Dec99 SF
''               '16Nov00 SF re-wrote return to ask the user if they want to remove the HIC transaction
''               ' remove the transaction that had been written
''               'sql$ = "DELETE * FROM transactions WHERE transactions.patrecno = '" & pid.recno & "' AND transactions.rxnumber = " & Format$(labf&) & " AND transactions.dispensingnumber = " & Format$(l.batchnumber) & ";"
''               'sql$ = "DELETE * FROM transactions WHERE transactions.patrecno = '" & pid.recno & "' AND transactions.rxnumber = " & Format$(l.prescriptionid) & " AND transactions.dispensingnumber = " & Format$(l.batchnumber) & ";"
''               'WriteLog patdatapath$ & "\RECOVER.PBS", 0, "", sql$
''               'PatDB.Execute (sql$): DoSaferEvents 1
''               '
''               '' check if any more tranactions left (was going to just check l.batchnumber=1 but that won't work for unoriginal supplies)
''               ''sql$ = "SELECT * FROM transactions WHERE transactions.patrecno = '" & pid.recno & "' AND transactions.rxnumber = " & Format$(labf&) & ";"
''               'sql$ = "SELECT * FROM transactions WHERE transactions.patrecno = '" & pid.recno & "' AND transactions.rxnumber = " & Format$(l.prescriptionid) & ";"
''               'Set snap = PatDB.CreateSnapshot(sql$)
''               '
''               'If snap.EOF Then
''               '      ' remove entry completly as if the drug was entered as new
''               '      l.batchnumber = 0
''               '      'sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber = " & Format$(labf&) & ";"
''               '      sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber = " & Format$(l.prescriptionid) & ";"
''               '      WriteLog patdatapath$ & "\RECOVER.PBS", 0, "", sql$
''               '      PatDB.Execute (sql$)
''               '   Else
''               '      ' decrement the number of repeats the patient has had for this item
''               '      l.batchnumber = l.batchnumber - 1
''               '   End If
''               ' snap.Close : Set snap = Nothing
''               ' DoSaferEvents 1
''               If l.batchnumber > 0 Then
''                     sql$ = "SELECT * FROM transactions WHERE transactions.patrecno = '" & pid.recno & "' AND transactions.prescriptionid = " & Format$(l.prescriptionid) & " AND transactions.dispensingnumber = " & Format$(l.batchnumber) & ";"
''                     Set dyn = Patdb.CreateDynaset(sql$)
''                     If Not dyn.EOF Then
''                           If GetField(dyn!hicstatus) = "C" Then     ' transaction already been processed and sent to HIC
''                                 txt$ = "The last transaction has already been sent to HIC in claim number: " & Format$(GetField(dyn!HICclaimNumber)) & cr
''                                 txt$ = txt$ & "Do you want to remove it completely from the patient billing database?"
''                              Else
''                                 txt$ = "Do you want to remove the last transaction to HIC from the patient billing database?"
''                              End If
''                           out$ = "N"
''                           askwin "?ASCribe Patient Billing", txt$, out$, k
''                           If (out$ = "Y") And (Not k.escd) Then
''                                 sglSafetyNetValue = GetField(dyn!SafetyNetValue) '07Apr03 TH (PBSv4) Added
''                                 dyn.Delete
''                                 l.batchnumber = l.batchnumber - 1
''                                 If l.batchnumber = 0 Then
''                                       ' returned all PBS dispensings so remove from repeats lookup table
''                                       sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber = " & Format$(l.prescriptionid) & ";"
''                                       WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''                                       Patdb.Execute (sql$): DoSaferEvents 1
''                                    End If
''                                 '07Apr03 TH (PBSv4) Added
''                                 On Error Resume Next
''                                 PatInfo.Edit
''                                 PatInfo!ThresholdAmount = PatInfo!ThresholdAmount - sglSafetyNetValue
''                                 PatInfo!Scripts = (PatInfo!Scripts) - 1
''                                 PatInfo.Update
''                                 'dispens.F3D1.Height = 200   '20Jun03 TH Replaced
''                                 dispens.F3D1.Height = 230    '    "
''                                 PBSRefreshPatDetails dispens.F3D1
''                                 On Error GoTo PatBillErr
''                                 '-------------------
''                              ElseIf (k.escd) Then
''                                 escd = True
''                              End If
''                        Else
''                           popmessagecr "#ASCribe Patient Billing", "Cannot find a HIC transaction to delete"
''                        End If
''                     dyn.Close: Set dyn = Nothing
''
''                  End If
''               '16Nov00 SF -----
''            End If
''
      ' get the correct PBS code from the NSV code given
      Case 15:
         'Might as well set the d type here !!!
         'GetProductbyDrugIDandSiteID DrugID
         
         
         'If billIt And BillingType = 2 Then       '17Dec99 SF replaced
         'If (billit) And (billingtype = 2) Then    '17Dec99 SF
               If txtReturn$ = "1" Then      ' 02Dec99 SF added to only fire on an issue
                  PBScode$ = ""           '16Nov00 SF added
                  manuCode$ = ""          '16Nov00 SF added
                  If ProductHasFormula() Then
                     AttachManuPBScode escd
                  Else
                     AttachManuPBScode escd '24Aug06 TH DEBUG MUST REMOVE !!!
                     '$$$TH Need to get the prescriber type here
                     SelectPBSitem escd, m_FoundDrugitem, "G"
                     'If (Not foundDrugitem) And (Not escd) Then  '19Mar03 TH (PBSv4) Added extra clause on escd  (#67236)
                     If (Not m_FoundDrugitem) And (Not escd) Then  '19Mar03 TH (PBSv4) Added extra clause on escd  (#67236)
                        PBSItemType$ = "N"
                        popmessagecr "#Patient Billing", "This is not currently a PBS subsidised item." & cr & "Any dispensings will have to be private."
                     End If
                     '16Nov00 SF -----
                  End If
               End If                     ' 02De99 SF added
         '   End If

      '**!! not implemented yet
      ' populate the formula table with one of the 3 char manufacturing(EP) PBS codes
      '16Nov00 SF removed following code as EP items are now selected in the pmr
      Case 16:
      '   txt$ = Trim$(TxTd(patdatapath$ & BillIniFile$, "PatientBilling", "", "MDBpathName", 0))
      '   Set db = OpenDatabase(txt$)
      '   sql$ = "SELECT * FROM epaverageprices ORDER BY description;"
      '
      '   Set snap = db.CreateSnapshot(sql$)
      '   If Not snap.EOF Then
      '         LstBoxFrm.LstBox.Clear
      '         LstBoxFrm.Caption = "ASCribe Patient Billing"
      '         LstBoxFrm.lblTitle = "Select the appropriate average price EP PBS code" & cr
      '         LstBoxFrm.lblHead = "PBS Code  Description" & Space$(30)
      '         Do While Not snap.EOF
      '            LstBoxFrm.LstBox.AddItem Trim$(getfield(snap!PBScode)) & TB & Trim$(getfield(snap!Description))
      '            snap.MoveNext
      '         Loop
      '         LstBoxShow
      '         If Trim$(LstBoxFrm.Tag) = "" Then
      '               ' user cancelled
      '               escd = True
      '            Else
      '               ' attach the chosen PBS code to the formula
      '               txt$ = Left$(LstBoxFrm.Tag, 3)      ' selected PBS code
      '               sql$ = "UPDATE formula SET pbscode = '" & txt$ & "' WHERE nsvcode = '" & d.SisCode & "';"
      '               OpenFormulaDatabase
      '               WriteLog patdatapath$ & "\RECOVER.PBS", 0, "", sql$
      '               DbFormula.Execute (sql$)
      '               dosaferevents 1
      '               CloseFormulaDatabase
      '            End If
      '         Unload LstBoxFrm
      '      End If
      '   snap.Close : Set snap = Nothing
      '   db.Close : Set db = Nothing
      '
      '16Nov99 SF -----
      '16Nov00 SF -----
      
      '02Dec99 SF added for clearing PBS billing data items on a label re-print
      Case 17:
''         'If billIt And BillingType = 2 Then ClearPatBillLbl            '17Dec99 SF relaced
''         'If (billIt) And (BillingType = 2) Then ClearPatBillLbl        '17Dec99 SF    '*16May00 SF now clears for all billing types
''       If billit Then ClearPatBillLbl                                                '*16May00 SF
''      '02Dec99 SF
''      '*16May00 SF added to return the original prescriber code regardless of what has been currently entered
      Case 18:
''         'If (billIt) And (BillingType = 1) Then                     '14Jul00 SF replaced
''         'If (billit) And (billingType = 1 Or billingType = 3) Then   '14Jul00 SF incorporated Repeat Dispensing  '16Nov00 SF replaced
''         If (billit) And (billingtype = 1 Or billingtype = 2 Or billingtype = 3) Then    '16Nov00 SF added PBS
''               SQL$ = "SELECT prescriberid FROM transactions WHERE prescriptionid = " & Format$(l.prescriptionid) & ";"
''               Set snap = Patdb.CreateSnapshot(SQL$)
''               If Not snap.EOF Then
''                     txtReturn$ = Trim$(GetField(snap!prescriberid))
''                  Else
''                     txtReturn$ = gPrescriberID$
''                  End If
''               snap.Close: Set snap = Nothing
''            End If
''      '*16May00 SF -----
      
      '16Nov00 SF added to return if PBS patient setup whether PBS,private,public
      Case 22:
         'If billit And (billingtype = 2) Then escd = True
         If billit Then escd = True
      '16Nov00 SF -----
      ' !!** put additional actions here
      
      '04Mar02 TH Added to check if a script is owed or not for MOJ rpt dispensing (#MOJ#)
      Case 23:
''               txtReturn$ = ""
''               If billingtype = 3 Then
''                     SQL$ = "SELECT Owed FROM transactions WHERE prescriptionid = " & Format$(l.prescriptionid) & ";"
''                     Set snap = Patdb.CreateSnapshot(SQL$)
''                     If Not snap.EOF Then
''                           If snap!Owed = True Then txtReturn$ = " (Prescription Owing)"    '!!!! ini replacement ?
''                        End If
''                     snap.Close: Set snap = Nothing
''                  End If
      
      Case 24:
''               txtReturn$ = ""
''               If billingtype = 3 Then
''                     SQL$ = "SELECT * FROM transactions WHERE prescriptionid = " & Format$(l.prescriptionid) & ";"
''                     Set dyn = Patdb.CreateDynaset(SQL$)
''                     If Not dyn.EOF Then
''                           If dyn!Owed = True Then
''                                 txt$ = "Enter Prescription Receipt Date"
''                                 strDateReceived = ""
''                                 Do
''                                    inputwin "ASCribe Patient Billing", txt$, strAns, k
''                                    If Not k.escd Then
''                                          parsedate strAns, Out$, "1", valid
''                                          If Not valid Then
''                                                txt$ = "The date entered was not valid" & cr & "Please enter the date the prescription was written"
''                                                strAns = ""
''                                             Else
''                                                ' check to make sure date entered is not in the future, if it is then warn the user
''                                                If Val(Right$(Out$, 4) & Mid$(Out$, 4, 2) & Left$(Out$, 2)) > Val(Format$(Now, "yyyymmdd")) Then
''                                                      ans$ = "N"
''                                                      askwin "?ASCribe Patient Billing", "The date entered is in the future." & cr & "Do you want to continue with this date?", ans$, k
''                                                      If (ans$ = "N") Or k.escd Then
''                                                            valid = False
''                                                            k.escd = True
''                                                            strAns = ""
''                                                         Else
''                                                            strDateReceived = Out$
''                                                         End If
''                                                   Else
''                                                      If strAns = Out$ Then
''                                                            strDateReceived = Out$
''                                                         Else
''                                                            strDateReceived = ""
''                                                            strAns = Out$
''                                                         End If
''                                                   End If
''                                             End If
''                                       End If
''                                 Loop Until Trim$(strDateReceived) <> "" Or (k.escd)
''                                 If Not k.escd And Trim$(strDateReceived) <> "" Then
''                                       dyn.Edit
''                                       dyn!Owed = False
''                                       dyn!DateOwingReceived = DateValue(strDateReceived)
''                                       dyn.Update
''                                       txtReturn$ = strDateReceived
''                                    End If
''                           Else
''                              popmessagecr "!Ascribe Patient Billing", "This prescription is not Owed"
''                           End If
''                        Else
''                           popmessagecr "!Ascribe Patient Billing", "No Transaction found for this prescription"
''                        End If
''                     dyn.Close: Set dyn = Nothing
''                  End If

      Case 25:
         
''         If (billit) And (billingtype = 3) Then escd = True       '04Mar02 Return if MOJ is set up

      '04Mar02 TH ---- (#MOJ#)

      Case 27:
''         billpatient = False ' false is the affimtaive "nothing is wrong" response. True cancels exit from ident.'True  ' 23Sep02 ATW ; By default, you should always apply stuff like PBS unless you have a reason not to
      
      '31Jan03 TH (PBSv4)  Sections Added
      Case 28:  'Was 23 Pre-Merge
         If (billit) And (intBillingtype = 2) Then
            If (foundDrugitem = True Or EPItem = True) Then
                  If Billitems$(53) = "R" Then
                     txtReturn$ = Format$(m_PBSProduct.maxqty * (Val(Billitems$(11)) + 1))
                  Else
                     txtReturn$ = Format$(m_PBSProduct.maxqty)
                  End If
                  If EPItem Then
                     If Trim$(UCase$(Format$(m_PBSProduct.IssueUnit))) <> Trim$(UCase$(d.PrintformV)) And d.mlsperpack > 0 Then txtReturn$ = Format$(Val(txtReturn$) / d.mlsperpack)
                  End If
            End If
         End If

      Case 29:  'Was 24 Pre-Merge
''         If (labf& <> 0 Or txtReturn$ = "Rchange") And Trim$(d.SisCode) <> "" Then
''            SQL$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(l.prescriptionid) & ";"
''            Set snap = Patdb.CreateSnapshot(SQL$)
''            If Not snap.EOF Then
''                  pbscode$ = Trim$(GetField(snap!pbscode))
''                  manuCode$ = Trim$(GetField(snap!manufacturerscode))
''                  If d.hasformula = "Y" Then
''                        SQL$ = "SELECT * FROM epaverageprices WHERE pbscode = '" & pbscode$ & "';"
''                        EPItem = True
''                     Else
''                        SQL$ = "SELECT * FROM pbsdrugs WHERE nsvcode = '" & d.SisCode & "' AND pbscode = '" & pbscode$ & "' AND manufacturerscode = '" & manuCode$ & "';"
''                        EPItem = False
''                     End If
''                  If Trim$(pbscode) <> "" Then     ' ignore private dispensings
''                        Set snpDrug = Patdb.CreateSnapshot(SQL$)
''                        If snpDrug.EOF Then
''                              foundDrugitem = False
''                           Else
''                              foundDrugitem = True
''                           End If
''                     Else
''                           foundDrugitem = False
''                     End If
''                  '07Mar03 TH (PBSv4) Added block
''                  'ElseIf PBSCode$ <> "" And manuCode$ <> "" Then
''                  '   If d.hasformula = "Y" Then
''                  '         sql$ = "SELECT * FROM epaverageprices WHERE pbscode = '" & PBSCode$ & "';"
''                  '         EPItem = True
''                  '      Else
''                  '         sql$ = "SELECT * FROM pbsdrugs WHERE nsvcode = '" & d.SisCode & "' AND pbscode = '" & PBSCode$ & "' AND manufacturerscode = '" & manuCode$ & "';"
''                  '         EPItem = False
''                  '      End If
''                  '   If Trim$(PBSCode) <> "" Then     ' ignore private dispensings
''                  '         Set snpDrug = Patdb.CreateSnapshot(sql$)
''                  '         If snpDrug.EOF Then
''                  '               foundDrugItem = False
''                  '            Else
''                  '               foundDrugItem = True
''                  '            End If
''                  '      Else
''                  '            foundDrugItem = False
''                  '      End If
''                  '---------------------------------------------
''
''               End If
''
''
''            snap.Close: Set snap = Nothing
''
''
''         End If

      Case 30:  'Was 25 Pre-Merge
''         foundDrugitem = False

      Case 31:  'Was 26 Pre-Merge
''         If (billit) And (billingtype = 2) And foundDrugitem Then escd = True

      '09Mar03 TH Added
      Case 33:
''         SQL$ = "SELECT * FROM pbsdrugs WHERE nsvcode = '" & d.SisCode & "';"
''         Set snpDrug = Patdb.CreateSnapshot(SQL$)
''         If snpDrug.EOF Then
''               escd% = False
''               'PBSItemStatus$ = "P"
''               'Billitems$(53) = "P"
''            Else
''               escd% = True
''               'PBSItemStatus$ = "P"
''               'Billitems$(53) = "P"
''            End If
         'snap.Close : Set snap = Nothing
      '----------------


   End Select
   
   billpatient = escd%
   

PatBillExit:
   '16Nov00 SF added
   On Error Resume Next
''   snap.Close: Set snap = Nothing
''   dyn.Close: Set dyn = Nothing
''   snapcheck.Close             '24Jun03 TH Added
''   Set snapcheck = Nothing     '    "

   '16Nov00 SF -----
   If FatalErr% Then
         ' do not allow any more patient billing for current patient.  Exiting the pmr and reloading a patient will try again.
         On Error Resume Next
''         setUpOk% = False
''         patfees.Close: Set patfees = Nothing
''         If patiententry% Then PatInfo.Close: Set PatInfo = Nothing
''         'If foundDrugitem% Then snpDrug.Close : Set snpDrug = Nothing  '28Apr03 TH Close now regardless - reports of memory errors from site.
''         snpDrug.Close: Set snpDrug = Nothing                           '   "
''         foundDrugitem = False      '31Jan03 TH (PBSv4) Added
'''         Patdb.Close: Set Patdb = Nothing
         popmessagecr ".Patient Billing", "A critical error has occured during patient billing" & cr & "Please contact the support desk for help"
      End If

   On Error GoTo 0
   Exit Function

PatBillErr:
   FatalErr% = True
   myError$ = Trim$(Error$)
   myErr = Err
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: BillPatient) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & myError$ & cr & "Error number: " & myErr             '16May00 SF replaced
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: BillPatient) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(l.prescriptionid) & " Error: " & myError$ & cr & "Error number: " & myErr   '16May00 SF                    '16Nov00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: BillPatient (Action: " & Format$(action) & ") for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & myError$ & cr & "Error number: " & myErr  '16Nov00 SF now reports action when errored
''   ClearPatBillLbl
   'popmessagecr ".ASCribe Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: BillPatient" & cr & "Error: " & myError$ & cr & "Error number: " & myErr                                    '16Nov00 SF replaced
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: BillPatient (Action: " & Format$(action) & ")" & cr & "Error: " & myError$ & cr & "Error number: " & myErr   '16Nov00 SF now reports action when errored
   Resume PatBillExit

End Function

Function CheckPBSIssue() As Integer
   CheckPBSIssue = False
End Function

Sub DoPatientBilling(tmwrkfunction As Integer, ASCbutton As Integer)
End Sub

Function isBilling() As Integer
   isBilling = False
   If (Val(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0)) = 2) Then
    isBilling = isPBS()
   End If
End Function
Public Function isPBS() As Boolean
'SQL STUB
   If m_blnKeepPBSDefaults Or (Not m_blnPBSDispenseOn) Then 'this can be turned off as we go through the issue
      isPBS = False              '    "
   Else                          '    "
      isPBS = True 'Ww wouldnt be here if it wasnt
   End If

End Function

Sub ItemTypeStatus(ByVal intMode, ByRef PBSOriginalRxDate$, ByRef strPBSAuthorityNum As String, ByRef strPBSOriginalApprovalnum As String, ByRef strDispensQuantity As String)
' Input Parameters:
'      writeIt = True then update table with PBSItemStatus$, PBSItemType$
'      writeIt = False then set PBSItemStatus$, PBSItemType$

' Current Type (PBSItemType$):
'      P = PBS Prescription
'      N = Private Prescription (Non-PBS)

' Current Status (PBSItemStatus$):
'      N = Normal Dispensing (default)
'      O = Emergency Dispensing (Prescription Owed)
'      D = Deferred Item (no issue, just a Rpt Auth form)
'      R = Regulation 24 (all repeats issued in one)
'      U = Unoriginal Prescription (ie. original dispensing from a different pharmacy)
Dim objBilling As Object
Dim strExceptionalDescription As String
Dim intExcepQty As Integer
Dim strXML As String
Dim lngResult As Long

Const Insert As Integer = 3
Const Update As Integer = -1


   ''On Error GoTo ItemStatusErr
   
   Select Case intMode
   Case Insert
      strExceptionalDescription = Billitems$(93)
      intExcepQty = Val(Billitems$(94))
      plingparse strExceptionalDescription, "'"  '07Apr03 TH Added
      '''''TH ***99PBS***
      'Set objBilling = CreateObject(m_strBillingComponent)
      'lngResult = objBilling.DrugRepeatInsert(g_SessionID, pid.recno, L.prescriptionid, Val(Billitems$(11)), 0, specialauthoritynum$, PBSCode$, manuCode$, solventPBScode$, Billitems$(59), PBSItemStatus$, PBSItemType$, strExceptionalDescription, intExcepQty)
      'Set objBilling = Nothing
      '
      '''''TH ***99PBS***
      'Set the type appropriately
      m_PBSDrugRepeat.PatRecNo = pid.recno
      m_PBSDrugRepeat.NumberOfRepeats = Val(Billitems$(11))
      m_PBSDrugRepeat.DispensQty = 0
      m_PBSDrugRepeat.SpecialAuthorityNum = SpecialAuthorityNum$
      m_PBSDrugRepeat.PBScode = PBScode$
      m_PBSDrugRepeat.ManufacturersCode = manuCode$
      m_PBSDrugRepeat.SolventCode = solventPBScode$
      m_PBSDrugRepeat.OriginalDate = Billitems$(59)
      m_PBSDrugRepeat.Status = PBSItemStatus$
      m_PBSDrugRepeat.Type = PBSItemType$
      m_PBSDrugRepeat.ExcepDescription = strExceptionalDescription
      m_PBSDrugRepeat.ExcepQty = intExcepQty
      m_PBSDrugRepeat.DrugID = d.DrugID '03Jun07 TH added
      PBSDrugRepeatWrite
      'WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
   Case Update 'status and type only
      'sql$ = "UPDATE drugrepeats SET drugrepeats.status = '" & PBSItemStatus$ & "' , drugrepeats.type = '" & PBSItemType$ & "' WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"    '16Nov00 SF fixed sql
      '''''TH ***99PBS***Set objBilling = CreateObject(m_strBillingComponent)
      'lngResult = objBilling.DrugRepeatUpdateStatusandType(g_SessionID, pid.recno, L.prescriptionid, PBSItemStatus$, PBSItemType$)
      'Set objBilling = Nothing
      '''''TH ***99PBS***
      'WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
      m_PBSDrugRepeat.Status = PBSItemStatus$
      m_PBSDrugRepeat.Type = PBSItemType$
      m_PBSDrugRepeat.DrugID = d.DrugID
      PBSDrugRepeatWrite
         
   Case Else 'Select
      '''''TH ***99PBS***
      'Set objBilling = CreateObject(m_strBillingComponent)
      ''31Aug06 TH Get result here in xml format
      'strXML = objBilling.DrugRepeatSelectForItemTypeStatus(g_SessionID, pid.recno, L.prescriptionid)
      'Set objBilling = Nothing
      '''''TH ***99PBS***
      '01Sep06 TH TODO use the DOM, Get the stuff send it out
      '14May07 TH We will already have this so we dont need to be in here !!!!!
      If Trim$(PBSItemStatus$) = "" Then PBSItemStatus$ = "N"
      If Trim$(PBSItemType$) = "" Then PBSItemType$ = "P"
   
   End Select
''   If writeIt = 3 Then
''      strExceptionalDescription = Billitems$(93)
''      intExcepQty = Val(Billitems$(94))
''      plingparse strExceptionalDescription, "'"  '07Apr03 TH Added
''      'sql$ = "INSERT INTO drugrepeats (patrecno, rxnumber, numberofrepeats, dispensqty, specialauthoritynum, pbscode, manufacturerscode, solventcode,originaldate,status,type, ExcepDescription,ExcepQty) VALUES ('" & pid.recno & "' , " & Format$(L.prescriptionid) & " , " & Val(Billitems$(11)) & " , 0 , '" & specialauthoritynum$ & "', '" & PBSCode$ & "', '" & manuCode$ & "', '" & solventPBScode$ & "', '" & Billitems$(59) & "', '" & PBSItemStatus$ & "', '" & PBSItemType$ & "', '" & strExceptionalDescription & "', " & intExcepQty & ");"  '07Apr03 TH (PBSv4)
''      Set objBilling = CreateObject(m_strBillingComponent)
''      lngResult = objBilling.DrugRepeatInsert(g_SessionID, pid.recno, L.prescriptionid, Val(Billitems$(11)), 0, specialauthoritynum$, PBSCode$, manuCode$, solventPBScode$, Billitems$(59), PBSItemStatus$, PBSItemType$, strExceptionalDescription, intExcepQty)
''      Set objBilling = Nothing
''      WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''      Patdb.Execute (sql$): DoSaferEvents 1
''   Else
''      If writeIt Then
''         'sql$ = "UPDATE drugrepeats SET drugrepeats.status = '" & PBSitemStatus$ & "' , drugrepeats.type = '" & PBSitemType$ & "';"      '16Nov00 SF replaced
''         sql$ = "UPDATE drugrepeats SET drugrepeats.status = '" & PBSItemStatus$ & "' , drugrepeats.type = '" & PBSItemType$ & "' WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"    '16Nov00 SF fixed sql
''         WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''         Patdb.Execute (sql$): DoSaferEvents 1
''      Else
''         'sql$ = "SELECT drugrepeats.status, drugrepeats.type FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
''         'sql$ = "SELECT drugrepeats.status, drugrepeats.type FROM drugrepeats WHERE drugrepeats.patrecno = '" & PID.recno & "' AND drugrepeats.rxnumber =" & Format$(l.prescriptionid) & ";"
''
''         sql$ = "SELECT drugrepeats.status, drugrepeats.type,drugrepeats.originaldate,drugrepeats.specialAuthorityNum,drugrepeats.originalapprovalnumber FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"  '31Jan03 TH (PBS v4)
''         Set snap = Patdb.CreateSnapshot(sql$)
''         opened% = True
''
''         If Not snap.EOF Then
''            If Trim$(GetField(snap!status)) <> "" Then PBSItemStatus$ = Trim$(GetField(snap!status))   '19Mar03 TH (PBSv4) Added if clause
''            If Trim$(GetField(snap!Type)) <> "" Then PBSItemType$ = Trim$(GetField(snap!Type))         '   "                                                        '08Mar03 TH/ATW Added $ to trim
''            PBSOriginalRxDate = Trim$(GetField(snap!originaldate))   '25Feb03 TH Replaced                           '   "
''            'PBSOriginalRxDate = Trim(getfield(snap!originalrxdate))  '    "
''            strPBSAuthorityNum = Trim$(GetField(snap!specialauthoritynum))           '31Jan03 TH (PBS v4) Added     '   "
''            strPBSOriginalApprovalnum = Trim$(GetField(snap!originalapprovalnumber)) '   "                          '   "
''            '19Mar03 TH (PBSv4) Added to set defaults if none exist
''            If Trim$(PBSItemStatus$) = "" Then PBSItemStatus$ = "N"
''            If Trim$(PBSItemType$) = "" Then PBSItemType$ = "P"
''            '--------------------------
''         Else
''            'PBSItemStatus$ = ""    '16Nov00 SF replaced
''            'PBSitemType$ = ""      '16Nov00 SF replaced
''            If Trim$(PBSItemStatus$) = "" Then PBSItemStatus$ = "N"    '16Nov00 SF default setting           '31Jan03 TH (PBS v4) Added if clause
''            If Trim$(PBSItemType$) = "" Then PBSItemType$ = "P"      '16Nov00 SF default setting             '   "
''            strPBSAuthorityNum = ""              '31Jan03 TH (PBS v4) Added
''            strPBSOriginalApprovalnum = ""       '   "
''         End If
''      End If
''   End If

ItemStatusExit:
   
   On Error GoTo 0
   Exit Sub

ItemStatusErr:
   FatalErr% = True
   PBSItemStatus$ = ""
   PBSItemType$ = ""
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: ItemStatus) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & Error$ & cr & "Error number: " & Err            '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: ItemStatus) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & Error$ & cr & "Error number: " & Err  '16May00 SF
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: ItemStatus" & cr & "Error: " & Error$ & cr & "Error number: " & Err
   Resume ItemStatusExit

End Sub

Sub PatBilling_Callback(ByVal index As Integer)
Dim pos%, txt$, Out$, valid%
Dim choice$          '16Nov99 SF added
Static prevIndex%    '16Nov99 SF added
Dim lines$(), X%, NumItems%
Dim extra$, tmp$, found%         '16Nov00 SF added to hold additional information given to the user
Dim schpbs As patidtype, maxnum%, sortcol%, foundpat&, PBSpidextra As PatIDTypeExtra, famdyn As Dynaset, SQL$, patientsearch$  '31Jan03 TH (PBSv4)
Dim NewNumber&, Msgtxt$                                     '31Jan03 TH (PBSv4)
Dim prevtypestr As String                                   '    "
Dim msg$                                                    '    "
Dim numoflines%                                             '    "
Dim dteTempDate As Variant                                  '    "
Dim intPaymentDefault As Integer, intNumofLines As Integer  '    "
Dim lngNumDays As Long '23Feb03 TH (PBSv4) Added
Dim strDateLastIssued As String   '24Feb03 TH (PBSv4) Added
Dim intOK As Integer     '16Mar03 TH (PBSv4) added
Dim ans As String, Q As String
     
   DoSaferEvents 0     '16Nov99 SF added to allow the showing of >1 modal form

   If index% < 0 Then
         ' help
         '16Nov99 SF added for PBS
         pos = Val(Ques.lblDesc(-index).Tag)
         ' dispensing action
         If pos = 53 Then
               frmoptionset -1, "Dispensing Action"
               frmoptionset 1, "P - PBS Dispensing"
               frmoptionset 1, "N - Non PBS Dispensing"
               frmoptionset 1, "O - Emergency Dispensing (Owed)"
               frmoptionset 1, "D - Defer Item"                      '20Nov99 SF corrected spelling
               frmoptionset 1, "U - Unoriginal Supply"
               frmoptionset 1, "R - Regulation 24"
               If Not blnPBSSuppressExceptional Then frmoptionset 1, "X - Non-Schedule Allowed Benefit"
               frmoptionshow "1", choice$
               frmoptionset 0, ""
               Select Case Val(choice$)
                  Case 1: Billitems$(pos%) = "P": QuesSetText -index, Billitems$(pos%)
                  Case 2: Billitems$(pos%) = "N": QuesSetText -index, Billitems$(pos%)
                  Case 3: Billitems$(pos%) = "O": QuesSetText -index, Billitems$(pos%)
                  Case 4: Billitems$(pos%) = "D": QuesSetText -index, Billitems$(pos%)
                  Case 5: Billitems$(pos%) = "U": QuesSetText -index, Billitems$(pos%)
                  Case 6: Billitems$(pos%) = "R": QuesSetText -index, Billitems$(pos%)
                  Case 7: Billitems$(pos%) = "X":
                  If Not blnPBSSuppressExceptional Then           '23Jul03 TH Added
                     Billitems$(pos%) = "X"                       '    "
                     QuesSetText -index, Billitems$(pos%)         '    "
                  Else                                            '    "
                     QuesSetText -index, Billitems$(pos%)
                  End If                                          '    "
                  Case Else: QuesSetText -index, Billitems$(pos%)
               End Select
               '23Feb03 TH Added block
               If Val(choice$) = 5 Then
               'set Unoriginal fields editable
                  QuesSetEnabled 88, True
                  QuesSetEnabled 89, True
                  QuesSetEnabled 90, True
                  QuesSetEnabled 91, True
                  'QuesSetEnabled 59, True
                  Billitems$(88) = ""   '17Mar03 TH Added (PBSv4)
                  QuesSetTextNoIndex 88, ""     '    " '18Mar03 TH (PBSv4) Use new wrapper
               Else
               'set Unoriginal fields disabled
                  QuesSetEnabled 88, False
                  QuesSetEnabled 89, False
                  QuesSetEnabled 90, False
                  QuesSetEnabled 91, False
                  'QuesSetEnabled 59, False
               End If
               '----------------
               '02Apr03 TH (PBSv4) Adde
               If Val(choice$) = 5 Then
               'set Exceptional fields editable
                  QuesSetEnabled 93, True
                  QuesSetEnabled 94, True
                  'QuesSetEnabled 59, True
               Else
               'set Exceptional fields disabled
                  QuesSetEnabled 93, False
                  QuesSetEnabled 94, False
               End If
               '----------------

            ' beneficiary type
            ElseIf pos = 56 Then
               frmoptionset -1, "Beneficiary Type"
               frmoptionset 1, "G - General Patient"
               frmoptionset 1, "C - Concessional Patient"
               'frmoptionset 1, "E - Entitlement Patient"      '16Nov00 SF removed, safety net now has it's own field
               frmoptionset 1, "R - Repatriation Patient"
               frmoptionshow "1", choice$
               frmoptionset 0, ""

               prevtypestr = Billitems$(pos%)    '15Jun01 TH %PBS%

               Select Case Val(choice$)
                  Case 1: Billitems$(pos%) = "G": QuesSetText -index, Billitems$(pos%)
                  Case 2: Billitems$(pos%) = "C": QuesSetText -index, Billitems$(pos%)
                  'Case 3: BillItems$(pos%) = "E": QuesSetText -index, BillItems$(pos%)      '16Nov00 SF removed, safety net now has it's own field
                  'Case 4: BillItems$(pos%) = "R": QuesSetText -index, BillItems$(pos%)      '16Nov00 SF replaced
                  Case 3: Billitems$(pos%) = "R": QuesSetText -index, Billitems$(pos%)       '16Nov00 SF
                  Case Else: QuesSetText -index, Billitems$(pos%)
               End Select
               '31Jan03 TH (PBSv4)  Validate after choice is made (if different)
               If UCase$(Trim$(Billitems$(pos%))) <> UCase$(Trim$(prevtypestr)) Then
                     Msgtxt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "PatTypeChangeMessage", 0)
                     ReDim lines$(10)                                  '31Jan03 TH (PBSv4) Changed to allow for multiple lines
                     deflines Msgtxt$, lines$(), "~", 1, numoflines    '   "
                     If numoflines > 1 Then                            '   "
                           Msgtxt$ = ""                                '   "
                           For X = 1 To numoflines                     '   "
                              Msgtxt$ = Msgtxt$ & lines$(X) & crlf     '   "
                           Next                                        '   "
                        End If                                         '   "
                     If Trim$(Msgtxt$) = "" Then
                           Msgtxt$ = "Please ensure you are progressing to the correct card ;" & crlf & crlf & "Beneficiary Type General to Concession Card "
                           Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Concession to Safety Number Card"
                           Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Repatriation to Safety Number Card"
                        End If
                     popmessagecr "#Patient Billing", Msgtxt$
                  End If
               '---------------------
            'Repatriation Card Type   31Jan03 TH (PBSv4) Added Repat Card Lookup
            ElseIf pos = 73 Then
               frmoptionset -1, "Repatriation Card Type"
               frmoptionset 1, "W - White Card"
               frmoptionset 1, "G - Gold Card"
               frmoptionset 1, "O - Orange Card"     '17Jul03 TH Added Orange
               frmoptionshow "1", choice$
               frmoptionset 0, ""
               Select Case Val(choice$)
                  Case 1: Billitems$(pos%) = "W": QuesSetText -index, Billitems$(pos%)
                  Case 2: Billitems$(pos%) = "G": QuesSetText -index, Billitems$(pos%)
                  Case 3: Billitems$(pos%) = "O": QuesSetText -index, Billitems$(pos%)    '17Jul03 TH Added Orange
                  Case Else: QuesSetText -index, Billitems$(pos%)
               End Select
            '-----------------------------------------
            
            '24Nov99 SF added to display relevant payment categories
            ElseIf pos = 62 Then
               NumItems = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "NumPRFpaymentTypes", 0))
               If NumItems = 0 Then
                     '16Nov00 SF replaced the following
                     'popmessagecr "#ASCribe Patient Billing", patdatapath$ & BillIniFile$ & cr & "[PBS] NumPRFpaymentTypes= not setup"
                     QuesSetText -index, ""
                     Billitems$(pos) = ""
                     '16Nov00 SF -----
                  Else
                     frmoptionset -1, "Payment Category"
                     ReDim lines$(4)       '31Jan03 TH (PBSv4) incremented
                     intPaymentDefault = 1 '31Jan03 TH (PBSv4) Added
                     For X = 1 To NumItems
                        txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", Format$(X), 0)
                        deflines txt$, lines$(), ",", 1, intNumofLines    '31Jan03 TH (PBSv4) use new intNumofLines param
                        frmoptionset 1, Trim$(lines$(1)) & " - " & Trim$(lines$(3))    ' code and description
                        If intNumofLines > 3 Then If Trim$(lines$(4)) = "-1" Then intPaymentDefault = X    '31Jan03 TH (PBSv4) Added
                     Next
                     
                     'frmoptionshow "1", choice$                           ''31Jan03 TH (PBSv4) Replaced
                     frmoptionshow Format$(intPaymentDefault), choice$     '    "
                     frmoptionset 0, ""
            
                     txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", choice$, 0)
                     deflines txt$, lines$(), ",", 1, 0
                     
                     If choice$ <> "" Then                          '16Nov00 SF added to allow for user escaping
                           QuesSetText -index, Trim$(lines$(1))     ' code to be written to transactions table for reporting purposes
                           Billitems$(pos) = Trim$(lines$(1))       '16Nov00 SF added to save choice
                        Else                                        '16Nov00 SF added to allow for user escaping
                           QuesSetText -index, Billitems$(pos)      '16Nov00 SF put back previous entry
                        End If                                      '16Nov00 SF added to allow for user escaping
                  End If
               '24Nov99 SF -----
            '16Nov00 SF added to for safety net card
            ElseIf pos = 58 Then
               frmoptionset -1, "Safety Net Card"
               frmoptionset 1, "No Safety Net Card"
               frmoptionset 1, "C - Safety Net Concession Card (CN)"
               frmoptionset 1, "E - Safety Net Entitlement Card (SN)"
               frmoptionshow "1", choice$
               frmoptionset 0, ""
               Select Case Val(choice$)
                  Case 1: Billitems$(pos) = " ": QuesSetText -index, Billitems$(pos)
                  Case 2: Billitems$(pos) = "C": QuesSetText -index, Billitems$(pos)
                  Case 3: Billitems$(pos) = "E": QuesSetText -index, Billitems$(pos)
                  Case Else: QuesSetText -index, Billitems$(pos)
               End Select
            If Billitems$(pos) = "C" And ((Billitems$(56) = "C") Or (Billitems$(58) = "R")) Then popmessagecr "#Patient Billing", "Warning, you have selected a CN entitlement card" & cr & "but the beneficiary type should have a SN card."
            If Billitems$(pos) = "E" And Billitems$(56) = "G" Then popmessagecr "#Patient Billing", "Warning, you have selected a SN entitlement card" & cr & "but the beneficiary type should have a CN card."
            
            ElseIf pos = 60 Then
                  ''GetPrescriberDetails True, "", found
                  'If found Then
                        'QuesSetText -index, Trim$(gPrescriberDetails.registrationNumber)                                                '31Jan03 TH (PBSv4) Replaced with below
                        QuesSetText -index, Trim$(m_Prescriber.registrationNumber) '& " (" & Trim$(gPrescriberDetails.name) & ")"  '    "
                        Ques.lblInfo(-index) = "Prescriber: " & gPrescriberID$ 'gPrescriberDetails                                       '    "
                  '   End If
            '31Jan03 TH (PBSv4) Added Block
            ElseIf pos = 68 Then       '31Jan03 TH (PBSv4)
                     'Patient search here should be safe as we will use only temporary(pbs) types seperate from main pat types                                                       '   "
''                     r.record = ""
''                     LSet schpbs = r
''                     k.escd = False
''                     patientsearch$ = ""
''                     inputwin "ASCribe Patient Billing", "Enter Patient Search to Establish Family Link or N for New Family Number", patientsearch$, k
''                     If Not k.escd And Trim$(patientsearch$) <> "" Then
''                           If Trim$(UCase$(patientsearch$)) = "N" Then
''                                 GetPointerSQL patdatapath$ & "\FamGroup.dat", NewNumber&, -1
''                                 Billitems$(pos%) = Format$(NewNumber&): QuesSetText -index, Billitems$(pos%)
''                              Else
''                                 frmlist.Tag = "PBS"
''                                 SelectPatient schpbs, maxnum, sortcol, patientsearch$
''                                 scanforpatients schpbs, maxnum, sortcol, foundpat, 0
''                                 frmlist.Tag = ""                           '   "
''                                 If foundpat > 0 Then
''                                    GetPIDExtra schpbs.recno, PBSpidextra
''                                       sql$ = "SELECT * FROM PatBilling WHERE patrecno = '" & Format$(schpbs.recno) & "';"
''                                       Set famdyn = PIDdb.CreateDynaset(sql)
''                                       If famdyn.RecordCount > 0 Then
''                                          msg$ = "Additional Patient Details : " & crlf & crlf & schpbs.forename & crlf & schpbs.surname & crlf & crlf & "Patient Address : " & crlf & crlf & PBSpidextra.Address1 & crlf & PBSpidextra.Address2 & crlf & PBSpidextra.Address3 & crlf & crlf & "Family number : " & Format$("0000000000", GetField(famdyn!Familygroupnumber)) & crlf & crlf & "OK to Link with this Patients Family ?" '02Jul01 TH %PBS%
''                                          askwin "?ASCribe: Patient Billing", msg$, ans$, k
''                                          If ans$ = "Y" And Not k.escd Then
''                                                Billitems$(pos%) = Format$(GetField(famdyn!Familygroupnumber)): QuesSetText -index, Billitems$(pos%)                                                                              '   "
''                                             End If
''                                       Else
''                                          MsgBox "No Family number set for this patient"
''                                       End If
''                                    Else
''                                       MsgBox "No Patient Can be found who matches this criteria"
''                                    End If
''                              End If
''                        End If
            ' Added OriginalDate Edit on PBS Screen
            ElseIf pos = 59 Then
                  X = billpatient(11, "")   '   "
                  QuesSetText -index, OriginalDate$
                  Billitems$(pos) = OriginalDate$
                 '31Jan03 TH (PBSv4) block end ----------------------------
            ElseIf pos = 89 Then
                  'x = billpatient(11, "")   '   "
                  'QuesSetText -index, tmp$
                  'BillItems$(pos) = tmp$
                 '31Jan03 TH (PBSv4) block end ----------------------------
                  txt$ = "Please enter the Last Issued Date"
                  ans$ = Billitems$(pos)
                  strDateLastIssued = ""
                  Do
                     inputwin "Patient Billing", txt$, ans$, k
                     If Not k.escd Then
                        parsedate ans$, Out$, "1", valid
                        If Not valid Then
                           BadDate
                           txt$ = "The date entered was not valid" & cr & "Please enter the date last issued"
                        Else
                           If ans$ <> Out$ Then
                              ans$ = Out$
                              txt$ = "Confirm date last issued"
                              inputwin "Patient Billing", txt$, ans$, k
                              parsedate ans$, Out$, "1", valid
                           End If
                           If Val(Right$(Out$, 4) & Mid$(Out$, 4, 2) & Left$(Out$, 2)) > Val(Format$(Now, "yyyymmdd")) Then
                                 If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "AllowFutureDateLastIssued", 0)) Then
                                    txt$ = "The date entered is in the future." & cr & "Do you want to continue with this date?"
                                    ans$ = "N"
                                    askwin "?Patient Billing", txt$, ans$, k
                                    If (ans$ = "N") Or k.escd Then
                                       valid = False
                                       k.escd = True
                                    End If
                                 Else
                                    txt$ = "A Date in the Future is invalid"
                                    popmessagecr "!Patient Billing", txt$
                                    valid = False
                                    k.escd = True
                                 End If
                           End If
                           If Not k.escd Then      '
                              datetodays Out$, Format$(Now, "dd/mm/yyyy"), lngNumDays, 0, "", 0
                              If lngNumDays <= 365 Then
                                 strDateLastIssued = Out$
                              Else
                                 txt$ = "The prescription has expired. A prescription is only valid for 12 months"
                              End If
                           End If
                        End If
                     End If
                  Loop Until Trim$(strDateLastIssued) <> "" Or (k.escd)
                  If Not k.escd Then                              '18Mar03 TH (PBSv4) Added
                     Billitems$(pos) = strDateLastIssued
                     QuesSetText Abs(index%), strDateLastIssued   '    "
                  End If                                          '    "
            End If
            '16Nov00 SF -----
         
         '16Nov99 SF -----
      ElseIf index = 0 Then
         ' OK pressed
         '16Nov00 SF added to allow user to verify the details
         'ans$ = "Y"
         'askwin "?ASCribe Patient Billing", "Are all the entries correct?", ans$, k
         'If ans$ = "N" Or k.escd Then ques.Tag = ""
         '16Nov00 SF -----
      ElseIf index = 1000 Then
         ' print option
         QuesPrintView "", ""
      Else
         pos% = Val(Ques.lblDesc(index%).Tag)   ' current field number
         txt$ = Trim$(QuesGetText(index%))      ' contents of current field
         Select Case pos%
            'Case 3, 6, 9, 25:               '16May00 SF replaced
            Case 3, 6, 9, 25, 30:            '16May00 SF added Item expiry date
               If Trim$(txt$) <> "" Then
                     parsedate txt$, Out$, "yyyymmdd", valid%
                     If valid% Then
                           If Val(Out$) < Val(Format$(Now, "yyyymmdd")) Then
                                 ' date expired
                                 QuesSetText index%, ""
                                 Billitems$(pos%) = ""
                              Else
                                 parsedate txt$, Out$, "8", valid%
                                 QuesSetText index%, Out$
                                 Billitems$(pos%) = Out$
                              End If
                        Else
                           QuesSetText index%, ""
                           Billitems$(pos%) = ""
                        End If
                  End If
            
            '31Jan03 TH (PBSv4) Added original rx date
            Case 59:
               If Trim$(txt$) <> "" Then
                     parsedate txt$, Out$, "8", valid%
                     If valid% And Val(Left$(Out$, 2)) > 0 And Val(Mid$(Out$, 4, 2)) > 0 Then
                           If DateDiff("d", Format(DateValue(Out$), "dd/mm/yyyy"), Format(Now, "dd/mm/yyyy")) < 0 Then
                              popmessagecr "#Patient Billing", "Warning, Invalid Original prescription date entered"
                              QuesSetText index%, ""
                              Billitems$(pos%) = ""
                           Else
                              '17Mar03 TH (PBSv4) Added block (#67144)
                              If Billitems(53) = "U" And Trim$(Billitems(89)) <> "" Then
                                 If DateDiff("d", Format(DateValue(Out$), "dd/mm/yyyy"), Format(Billitems(89), "dd/mm/yyyy")) < 0 Then
                                    popmessagecr "#Patient Billing", "Warning, Invalid Original prescription date entered" & crlf & "Cannot be after the Unoriginal Date Last Issued"
                                    QuesSetText index%, ""
                                    Billitems$(pos%) = ""
                                 Else
                                    QuesSetText index%, Out$
                                    Billitems$(pos%) = Out$
                                    datePrescriptionWritten$ = Out$
                                    OriginalDate$ = Out$ 'Use originaldate, hopefully dateprescriptionwritten will now be obselete
                                 End If
                              Else
                              '------------------------
                                 QuesSetText index%, Out$
                                 Billitems$(pos%) = Out$
                                 datePrescriptionWritten$ = Out$
                                 OriginalDate$ = Out$ 'Use originaldate, hopefully dateprescriptionwritten will now be obselete
                              End If    '17Mar03 TH (PBSv4) Added
                           End If                                                                                            '   "
                        Else
                           popmessagecr "#Patient Billing", "Warning, Invalid Original prescription date entered"
                           QuesSetText index%, ""
                           Billitems$(pos%) = ""
                        End If
                  Else                          '17Mar03 TH (PBSv4) Added (#67144) Allows blank so should update array ?
                     QuesSetText index%, ""     '    "
                     Billitems$(pos%) = ""      '    "
                  End If
            '---------------------------------------
            Case 1, 4, 7
               Billitems$(pos%) = txt$    '22Jul99 SF added
               If txt$ = "Y" Then
                     Ques.txtQ(index% + 1).Enabled = True
                     Ques.txtQ(index% + 2).Enabled = True
                  Else
                     Ques.txtQ(index% + 1).Enabled = False
                     Ques.txtQ(index% + 2).Enabled = False
                  End If
            
            '16Nov99 SF added the following for PBS
            ' concession card number
            Case 51:
               valid = True
               If Billitems$(56) = "C" Then
                     'ValidateCardNumber BillItems$(51), "C", valid   '31Jan03 TH (PBSv4)
                     ValidateCardNumber txt$, "C", valid              '    "
                  ElseIf Billitems$(56) = "R" Then
                     'ValidateCardNumber BillItems$(51), "R", valid   '    "
                     ValidateCardNumber txt$, "R", valid              '    "
                  '16Nov00 SF added
                  ElseIf Trim$(txt$) <> "" Then
                    popmessagecr "#Patient Billing", "Warning, Benefit type must be either" & cr & "Concession or Repatriation"
                  '16Nov00 SF -----
                  End If
               If valid Then
                     Billitems$(pos) = Trim$(txt$)
                  Else
                     QuesSetText index, ""
                     Billitems$(pos) = ""
                  End If
            Case 52:
            ' format concession card expiry date
               If Billitems$(56) = "C" Or Billitems$(56) = "R" Then     '16Nov00 SF added
                    If Trim$(txt$) <> "" Then                           '16Nov00 SF added to allow blanking of the date
                            'parsedate txt$, out$, "1", 0               '16Nov00 SF replaced
                            parsedate txt$, Out$, "1", valid            '16Nov00 SF
                            If valid Then                               '16Nov00 SF if valid date entered do as before
                                QuesSetText index, Out$
                                Billitems$(pos%) = Out$
                            '16Nov00 SF handle bad date
                            'Else                                                                                        '31Jan03 TH (PBSv4) Added
                            ElseIf TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "PBSConcessionExpiry", 0)) Then  '   "
                                popmessagecr "#Patient Billing", Q$ & Out$ & Q$ & " is an invalid date"
                                QuesSetText index, Billitems$(pos)
                            End If
                            '16Nov00 SF -----
                        End If                                    '16Nov00 SF added
                '16Nov00 SF added
                ElseIf Trim$(txt$) <> "" Then
                    popmessagecr "#Patient Billing", "Warning, Benefit type must be either" & cr & "Concession or Repatriation"
                '16Nov00 SF -----
                End If
            Case 53:
            ' validate dispensing actions
               If Not foundDrugitem Then
                  intOK = 0                                             '16Mar03 TH (PBSv4) Added to allow saved but not issued lines to be
                  '01Jun07 TH If L.batchnumber = 0 Then                             '    "      Recognised not necessarily as private items
                  If m_PBSDrugRepeat.NumberOfIssues = 0 Then
                     intOK = billpatient(33, "")                        '    "
                  End If                                                '    "
                  'If Trim$(UCase$(txt$)) <> "N" Then                   '    "
                  If (Trim$(UCase$(txt$)) <> "N") And intOK = 0 Then    '    "                                                   '30Apr03 TH %PBS% Added '01May03 TH Reverted - over exuberance from Oz thank God
                  'If ((Trim$(UCase$(txt$)) <> "N") And intOK = 0) And ((Trim$(UCase$(txt$)) <> "X") Or l.batchnumber > 0) Then    '    "                '   "       If not on Schedule must be private as previously agreed
                     popmessagecr "#Patient Billing", "This is not currently a PBS subsidised item." & cr & "Any dispensings will have to be private."
                     Billitems$(pos%) = "N"
                  End If
               'Else
               End If                              '16Mar03 TH (PBSv4) Added
               If (intOK Or foundDrugitem) Then    '    "
                  If blnPBSSuppressExceptional And Trim$(txt$) = "X" Then         '23Jul03 TH Added '24Jul03 TH Added Clause
                     popmessagecr "#Patient Billing", "Exceptional Pricing Must Be Set Before Beginning To Issue - Please reverse the transaction and start again."
                     QuesSetText Abs(-index), Billitems$(pos)    '24Feb03 TH (PBSv4) Moved from above
                     'valid = False
                  Else
                     Select Case Trim$(txt$)
                        Case "P", "O", "D", "R", "T", "U", "N", "X":  '01Apr03 TH Added "X"
   
                           '01Jun07 TH If L.batchnumber = 0 Then
                           If m_PBSDrugRepeat.NumberOfIssues = 0 Then
                                    'If PBSitemType$ = "N" And (Trim$(txt$) <> "N" And Trim$(txt$) <> "D") Then           '31Jan03 TH (PBSv4) Removed as PBSitemType$ now being set at wrong stage
                                    '      index = prevIndex                                                              '   "
                                    '      billitems$(pos%) = "N"                                                         '   "
                                    '      popmessagecr "#Patient Billing", "Can only dispense as a private item" '   "
                                    '   Else                                                                              '   "
                                          If (Trim$(Billitems$(pos%)) <> Trim$(txt$)) And (Trim$(UCase$(txt$)) = "U") Then   '17Mar03 TH Added (PBSv4)
                                             Billitems$(88) = ""                                                             '   "
                                             'QuesSetText 88, ""        '18Mar03 TH (PBSv4) Replaced                                                         '   "
                                             QuesSetTextNoIndex 88, ""  '    "      Use new wrapper
                                          End If                                                                             '   "
   
                                          Billitems$(pos%) = Trim$(txt$)
                                    '   End If                                                                            '   "
                              Else
                                 Select Case Trim$(txt$)
                                    Case "O":
                                       'index = prevIndex  '24Feb03 TH(PBSv4) Removed
                                       'BillItems$(pos%) = Trim$(txt$)      '16Nov00 SF removed
                                       'QuesSetText Abs(-index), BillItems$(pos)  '16Nov00 SF added to set to previous good selection  '24Feb03 TH (PBSv4) Added abs
                                       popmessagecr "#Patient Billing", "Cannot owe on a repeat"
                                       QuesSetText Abs(-index), Billitems$(pos) '24Feb03 TH (PBSv4) Moved from above
                                    Case "R":
                                       'index = prevIndex  '24Feb03 TH(PBSv4) Removed
                                       'BillItems$(pos%) = Trim$(txt$)      '16Nov00 SF removed
                                       'QuesSetText Abs(-index), BillItems$(pos)  '16Nov00 SF added to set to previous good selection '24Feb03 TH (PBSv4) Added abs
                                       popmessagecr "#Patient Billing", "Regulation 24 not valid on a repeat"
                                       QuesSetText Abs(-index), Billitems$(pos) '24Feb03 TH (PBSv4) Moved from above
                                    Case "U":
                                       'index = prevIndex  '24Feb03 TH(PBSv4) Removed
                                       'BillItems$(pos%) = Trim$(txt$)      '16Nov00 SF removed
                                       'QuesSetText Abs(-index), BillItems$(pos)  '16Nov00 SF added to set to previous good selection '24Feb03 TH (PBSv4) Added abs
                                       popmessagecr "#Patient Billing", "Cannot be an unoriginal on a repeat"
                                       QuesSetText Abs(-index), Billitems$(pos) '24Feb03 TH (PBSv4) Moved from above
                                    Case "P", "N", "X":                              '01Apr03 TH (PBSv4)Added "X"
                                       If Trim$(txt$) <> PBSItemType$ Then
                                             'index = prevIndex   '24Feb03 TH(PBSv4) Removed
                                             'BillItems$(pos%) = Trim$(txt$)      '16Nov00 SF removed
                                             'QuesSetText Abs(-index), BillItems$(pos)  '16Nov00 SF added to set to previous good selection   '24Feb03 TH (PBSv4) Added abs
                                             popmessagecr "#Patient Billing", "Cannot change prescription type on a repeat"
                                             QuesSetText Abs(-index), Billitems$(pos) '24Feb03 TH (PBSv4) Moved from above
                                          Else
                                             Billitems$(pos%) = Trim$(txt$)
                                          End If
                                    Case "D":
                                       'index = prevIndex   '24Feb03 TH(PBSv4) Removed
                                       'BillItems$(pos%) = Trim$(txt$)      '16Nov00 SF removed
                                       QuesSetText Abs(-index), Billitems$(pos)  '16Nov00 SF added to set to previous good selection  '24Feb03 TH (PBSv4) Added abs
                                       popmessagecr "#Patient Billing", "Cannot defer on a repeat"
                                    Case Else:
                                       Billitems$(pos%) = Trim$(txt$)
                                 End Select
                              End If
                              '23Feb03 TH Added block
                              If Billitems$(pos%) = "U" Then
                              'set Unoriginal fields editable
                                 QuesSetEnabled 88, True
                                 QuesSetEnabled 89, True
                                 QuesSetEnabled 90, True
                                 QuesSetEnabled 91, True
                                 'QuesSetEnabled 59, True
                                 'Clear the authority number (#67012)
                                 'Billitems$(66) = ""    '16Mar03 TH Added (PBSv4)
                                 'QuesSetText 66, ""     '    "
                                 'Clear the approval number (not authority !!!) (#67012)
                                 'Billitems$(88) = ""   '17Mar03 TH Added (PBSv4) Removed
                                 'QuesSetText 88, ""     '    "
                              Else
                              'set Unoriganal fields disabled
                                 QuesSetEnabled 88, False
                                 QuesSetEnabled 89, False
                                 QuesSetEnabled 90, False
                                 QuesSetEnabled 91, False
                                 'QuesSetEnabled 59, False
                              End If
                              '----------------
                              '01Apr03 TH Added block
                              If Billitems$(pos%) = "X" Then
                              'set Exceptional fields editable
                                 QuesSetEnabled 93, True
                                 QuesSetEnabled 94, True
                              Else
                              'set Exceptional fields disabled
                                 QuesSetEnabled 93, False
                                 QuesSetEnabled 94, False
                              End If
                              '----------------
   
   
                     Case Else:
                        '16Nov00 SF added
                        extra$ = cr & cr & "Valid entries:" & cr
                        extra$ = extra$ & Q$ & "P" & Q$ & " - PBS Dispensing" & cr
                        extra$ = extra$ & Q$ & "N" & Q$ & " - Non PBS Dispensing" & cr
                        extra$ = extra$ & Q$ & "O" & Q$ & " - Emergency Dispensing (Owed)" & cr
                        extra$ = extra$ & Q$ & "D" & Q$ & " - Defer Item" & cr
                        extra$ = extra$ & Q$ & "U" & Q$ & " - Unoriginal Supply" & cr
                        extra$ = extra$ & Q$ & "R" & Q$ & " - Regulation 24" & cr
                        extra$ = extra$ & Q$ & "X" & Q$ & " - Non-Schedule Allowed Benefit" & cr    '01Apr03 TH (PBSv4) Added
                        '16Nov00 SF -----
                        'BillItems$(pos%) = Trim$(txt$)     '16Nov00 SF removed
                        'popmessagecr "#Patient Billing", Trim$(txt$) & " is an invalid action"               '16Nov00 SF replaced
                        popmessagecr "#Patient Billing", Q$ & txt$ & Q$ & " is an invalid action" & extra$    '16Nov00 SF
                        QuesSetText index, Billitems$(pos)  '16Nov00 SF added to set to previous good selection
                  End Select
               End If        '23Jul03 TH added
            'ElseIf ((Trim$(UCase$(txt$)) = "X") And l.batchnumber = 0) Then  '30Apr03 TH %PBS% Added '01May03 TH Reverted - see above
            '   'set Exceptional fields editable                              '   "
            '   QuesSetEnabled 93, True                                       '   "
            '   QuesSetEnabled 94, True                                       '   "
            '   Billitems$(pos%) = Trim$(txt$)                                '   "
            End If '31Jan03 TH (PBSv4) Added - Merge error ?

            
            ' validate beneficiary types
            Case 56:
               Select Case Trim$(txt$)
                  'Case "G", "C", "E", "R":           '16Nov00 SF replaced
                  Case "G", "C", "R":                 '16Nov00 SF
                     '17May01 TH %PBS%
                     If UCase$(Trim$(Billitems$(pos%))) <> UCase$(Trim$(txt$)) Then
                           Msgtxt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "PatTypeChangeMessage", 0)
                           ReDim lines$(10)                                  '31Jan03 TH (PBSv4) Changed to allow for multiple lines
                           deflines Msgtxt$, lines$(), "~", 1, numoflines    '   "
                           If numoflines > 1 Then                            '   "
                                 Msgtxt$ = ""                                '   "
                                 For X = 1 To numoflines                     '   "
                                    Msgtxt$ = Msgtxt$ & lines$(X) & crlf     '   "
                                 Next                                        '   "
                              End If                                         '   "
                           If Trim$(Msgtxt$) = "" Then
                                 Msgtxt$ = "Please ensure you are progressing to the correct card ;" & crlf & crlf & "Beneficiary Type General to Concession Card "
                                 Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Concession to Safety Number Card"
                                 Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Repatriation to Safety Number Card"
                              End If
                           popmessagecr "#Patient Billing", Msgtxt$
                        End If
                     '---------------------
                     Billitems$(pos%) = Trim$(txt$)
                  Case Else:
                     '16Nov00 SF added
                     extra$ = cr & cr & "Valid entries:" & cr
                     extra$ = extra$ & Q$ & "G" & Q$ & " - General Patient" & cr
                     extra$ = extra$ & Q$ & "C" & Q$ & " - Concessional Patient" & cr
                     extra$ = extra$ & Q$ & "R" & Q$ & " - Repatriation Patient" & cr
                     '16Nov00 SF -----
                     'BillItems$(pos%) = Trim$(txt$)     '16Nov00 SF removed
                     'popmessagecr "#Patient Billing", Trim$(txt$) & " is an invalid beneficiary type"              '16Nov00 SF replaced
                     popmessagecr "#Patient Billing", Q$ & txt$ & Q$ & " is an invalid beneficiary type" & extra$   '16Nov00 SF
                     QuesSetText index, Billitems$(pos)  '16Nov00 SF added to set to previous good selection
               End Select
            '16Nov00 SF added to validate the safety net entitlement field
            Case 58
               Select Case txt$
                  Case "C", "E", " ", "":
                     Billitems$(pos%) = Trim$(txt$)
                     If Billitems$(pos) = "C" And ((Billitems$(56) = "C") Or (Billitems$(58) = "R")) Then popmessagecr "#Patient Billing", "Warning, you have selected a CN entitlement card" & cr & "but the beneficiary type should have a SN card."
                     If Billitems$(pos) = "E" And Billitems$(56) = "G" Then popmessagecr "#Patient Billing", "Warning, you have selected a SN entitlement card" & cr & "but the beneficiary type should have a CN card."
                  Case Else:
                     extra$ = cr & cr & "Valid entries:" & cr
                     extra$ = extra$ & Q$ & " " & Q$ & " - No Safety Net Card" & cr
                     extra$ = extra$ & Q$ & "C" & Q$ & " - Safety Net Concession Card (CN)" & cr
                     extra$ = extra$ & Q$ & "E" & Q$ & " - Safety Net Entitlement Card (SN)" & cr
                     popmessagecr "#Patient Billing", Q$ & txt$ & Q$ & " is an invalid safety net type" & extra$
                     QuesSetText index, Billitems$(pos)
               End Select
            
            Case 62
                  NumItems = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "NumPRFpaymentTypes", 0))
                  found = False
                  ReDim lines$(3)
                  extra$ = cr & cr & "Valid entries:" & cr
                  For X = 1 To NumItems
                     tmp$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", Format$(X), 0)
                     deflines tmp$, lines$(), ",", 1, 0
                     If txt$ = Trim$(lines$(1)) Then found = True
                     extra$ = extra$ & Q$ & Trim$(lines$(1)) & Q$ & " - " & Trim$(lines$(3)) & cr
                  Next
                  If Not found Then
                        popmessagecr "#Patient Billing", Q$ & txt$ & Q$ & " is an incorrect payment category" & extra$
                        QuesSetText index, Billitems$(pos)
                     Else
                        Billitems$(pos%) = Trim$(txt$)
                     End If
            '16Nov00 SF -----
            
            ' safety net card number
            Case 57:
               valid = True
               If Billitems$(58) = "C" Then
                     'ValidateCardNumber BillItems$(51), "C", valid   '31Jan03 TH (PBSv4)
                     ValidateCardNumber txt$, "E", valid              '    "
                  ElseIf Billitems$(58) = "E" Then
                     'ValidateCardNumber BillItems$(51), "E", valid   '   "
                     ValidateCardNumber txt$, "E", valid              '   "
                  '16Nov00 SF added
                  ElseIf Trim$(txt$) <> "" Then
                    popmessagecr "#Patient Billing", "Warning, You must have a valid safety net benefit type"
                  '16Nov00 SF -----
                  End If
               If valid Then
                     '31Jan03 TH (PBSv4) Added Block
                     If UCase$(Trim$(Billitems$(pos%))) <> UCase$(Trim$(txt$)) Then
                           Msgtxt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "SNCardChangeMessage", 0)
                           ReDim lines$(10)
                           deflines Msgtxt$, lines$(), "~", 1, numoflines
                           If numoflines > 1 Then
                                 Msgtxt$ = ""
                                 For X = 1 To numoflines
                                    Msgtxt$ = Msgtxt$ & lines$(X) & crlf
                                 Next
                              End If

                           If Trim$(Msgtxt$) = "" Then
                                 Msgtxt$ = "Please ensure you are progressing to the correct card ;" & crlf & crlf & "Beneficiary Type General to Concession Card "
                                 Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Concession to Safety Number Card"
                                 Msgtxt$ = Msgtxt$ & crlf & crlf & "Beneficiary Type Repatriation to Safety Number Card"
                              End If
                           popmessagecr "#Patient Billing", Msgtxt$
                        End If
                     '------------------------
                     Billitems$(pos) = Trim$(txt$)
                  Else
                     QuesSetText index, ""
                     Billitems$(pos) = ""
                  End If
               
            ' if issuing more repeats than max allowed then ensure special authority or private prescription
            Case 11:
               k.escd = False    '16Nov00 SF added to ensure cancel if false if none of the following questions asked
               '01Jun07 TH If L.batchnumber = 0 And (foundDrugitem = True Or EPItem = True) Then
               If m_PBSDrugRepeat.NumberOfIssues = 0 And (foundDrugitem = True Or EPItem = True) Then
                     If Trim$(SpecialAuthorityNum$) = "" Then
                           If Val(txt$) > m_PBSProduct.MaxRepeats Then
                                 valid = True
                                 Do
                                    ans$ = ""
                                    k.nums = True
                                    inputwin "Patient Billing", Trim$(txt$) & " repeats is above the PBS Max of " & Format$(m_PBSProduct.MaxRepeats) & " for this item" & cr & "To prescribe more a special authority is required or the" & cr & "prescription must be private." & cr & cr & "Enter authority number to continue" & cr & "or leave blank for a private prescription.", ans$, k   '08Mar03 TH/ATW Added $ to trim
                                    If Not k.escd Then
                                          If Trim$(ans$) <> "" Then
                                                ValidateCardNumber ans$, "A", valid
                                                If valid Then
                                                      ' special authority granted
                                                      SpecialAuthorityNum$ = ans$
                                                      PBSItemType$ = "P"
                                                      Ques.lblInfo(index) = "Authority# " & Trim$(SpecialAuthorityNum$)    '16Nov00 SF added
                                                   End If
                                             Else
                                                '  private prescription
                                                PBSItemType$ = "N"
                                                Ques.lblInfo(index) = "Private Dispensing"                                 '16Nov00 SF added
                                                m_blnPBSPrivateDispensing = True      '09Mar03 TH (PBSv4) Added
                                             End If
                                       Else              '16Nov00 SF added to allow exiting of loop when cancel pressed
                                          valid = True   '16Nov00 SF added to allow exiting of loop when cancel pressed
                                          PBSItemType$ = "N"                             '09Mar03 TH (PBSv4) Added - private is escape
                                          Ques.lblInfo(index) = "Private Dispensing"     '     "
                                          m_blnPBSPrivateDispensing = True               '09Mar03 TH (PBSv4) Added
                                       End If
                                 Loop Until valid
                              End If
                        End If
                  End If
               If (Not k.escd) Then                      '16Nov00 SF added to deal with cancel
                     Billitems$(pos%) = txt$
                  Else                                   '16Nov00 SF added to deal with cancel
                     QuesSetText index, Billitems$(pos)  '16Nov00 SF added to deal with cancel
                  End If                                 '16Nov00 SF added to deal with cancel
            
            '16Nov99 SF -----
            
            Case 73: '31Jan03 TH (PBSv4)
                  'If InStr("GW", txt$) = 0 Then
                  If InStr("GWO", UCase(txt$)) = 0 Then    '17Jul03 TH Added Orange
                        popmessagecr ".Patient Billing", "Invalid Repatriation Card Type Selected" & crlf & crlf & "Valid Types are ;" & crlf & crlf & "W - White" & crlf & "G - Gold" & crlf & "O - Orange"    '17Jul03 TH Added Orange
                        QuesSetText index, ""
                        Billitems$(pos) = ""
                     Else
                        Billitems$(pos) = UCase(txt$)
                        QuesSetText index, UCase(txt$)
                     End If
                     'Block end -----------------------
            '31Jan03 TH (PBSv4) Added Medicare and Subnumerate Number Checking
            Case 67, 85:   '31Jan03 TH (PBSv4) Added Temporary Medicare number to checking routine
               valid = True
               ValidateCardNumber txt$, "M", valid
               If valid Then
                     Billitems$(pos) = Trim$(txt$)
                  Else
                     QuesSetText index, ""
                     Billitems$(pos) = ""
                  End If
            Case 69:
               valid = True
               If (Len(Trim$(txt$)) <> 1 And Trim$(txt$) <> "") Or (InStr(1, "0123456789", Trim$(txt$)) = 0 And Trim$(txt$) <> "") Then valid = False
                  
               If valid Then
                     Billitems$(pos) = Trim$(txt$)
                  Else
                     '13Aug01 TH %PBS% NEEDS RESOLVING
                     popmessagecr ".Patient Billing", "Invalid Subnumerate Selected" & crlf & crlf & "Valid Subnumerate entries must be single digits"
                     QuesSetText index, ""
                     Billitems$(pos) = ""
                  End If
            '----------------------------------------------------------
            '31Jan03 TH (PBSv4) Expiry date for Medicare card (no validation as yet - needs mmyyyy) - Done
            Case 70:
               If Trim$(txt$) <> "" Then
                        If Len(Trim$(txt$)) <> 6 Then
                           popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be mmyyyy"
                           QuesSetText index, Billitems$(pos)
                        Else
                           parsedate "01" & txt$, Out$, "3", valid
                           If valid Then
                              On Error Resume Next
                              dteTempDate = DateValue("01/" & Left$(txt$, 2) & "/" & Right$(txt$, 4))
                              If Err Then
                                 Err = 0
                                 popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be mmyyyy"
                                 QuesSetText index, Billitems$(pos)
                              Else
                                 If DateDiff("d", Format(dteTempDate, "dd/mm/yyyy"), Format(Now, "dd/mm/yyyy")) > 0 Then
                                    popmessagecr "#Patient Billing", "Expiry Date Must be in the future"
                                    'QuesSetText index, BillItems$(pos)  '07Mar03 TH (PBSv4) Altered (#)
                                    QuesSetText index, ""                '    "
                                    Billitems$(pos) = ""                 '    "
                                 Else
                                    QuesSetText index, txt$
                                    Billitems$(pos%) = txt$
                                 End If
                              End If
                           Else
                              popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be mmyyyy"
                              QuesSetText index, Billitems$(pos)
                           End If
                        End If
                  End If
                  
            Case 86: 'Temp Expiry - needs ddmmyy
               If Trim$(txt$) <> "" Then
                        If Len(Trim$(txt$)) <> 6 Then
                           popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be ddmmyy"
                           QuesSetText index, Billitems$(pos)
                        Else
                           parsedate txt$, Out$, "1", valid
                           If valid Then
                              On Error Resume Next
                              dteTempDate = DateValue(Out$)
                              If Err Then
                                 Err = 0
                                 popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be ddmmyy"
                                 QuesSetText index, Billitems$(pos)
                              Else
                                 If DateDiff("d", Format(dteTempDate, "dd/mm/yyyy"), Format(Now, "dd/mm/yyyy")) > 0 Then
                                    popmessagecr "#Patient Billing", "Expiry Date Must be in the future"
                                    QuesSetText index, Billitems$(pos)
                                 Else
                                    QuesSetText index, txt$
                                    Billitems$(pos%) = txt$
                                 End If
                              End If
                           Else
                              popmessagecr "#Patient Billing", txt$ & " is an invalid date " & crlf & crlf & "Format should be ddmmyy"
                              QuesSetText index, Billitems$(pos)
                           End If
                        End If
                  End If
            '31Jan03 TH (PBSv4) Added Repat number to checking routine
            Case 72:
               valid = True
               ValidateCardNumber txt$, "R", valid
               If valid Then
                     Billitems$(pos) = Trim$(txt$)
                  Else
                     QuesSetText index, ""
                     Billitems$(pos) = ""
                  End If
            '---------------------------------------------------
               'Validate Unoriginal Supply fields   '23Feb03 TH (PBSv4) Added
               '18Mar03 TH (PBSv4) Added block (#67146)
               Case 88:
                  If Billitems$(53) = "U" Then
                     If Trim$(txt$) = "" Then
                        valid = False
                        popmessagecr "#Patient Billing", "Warning, Unoriginal Supply requires Original Approval Number"
                        QuesSetText index, ""
                     Else
                        Billitems$(pos%) = txt$
                     End If
                  End If
               '--------------------------

               Case 89:
               If Billitems$(53) = "U" Then
               'Last Issued Date
                  'valid = True
                  'parsedate txt$, txt$, "1", valid
                  'If Not valid Then
                  '   popmessagecr "#Patient Billing", "Unoriginal Supply - Original Date is Invalid"
                  '   QuesSetText index, ""
                  '   BillItems$(pos) = ""
                  'ElseIf txt$ <> "date expired" Then
                  '   datetodays txt$, Format$(Now, "dd/mm/yyyy"), lngNumDays, 0, "", 0
                  '   If lngNumDays <= 365 Then
                  '      BillItems$(pos) = txt$
                  '   Else
                  '      BillItems$(pos) = "expired"
                  '      popmessagecr "#Patient Billing", "The prescription has expired. A prescription is only valid for 12 months"
                  '   End If
                  'End If
                  'If valid Then
                  '   BillItems$(pos) = Trim$(txt$)
                  'End If
                  '24Feb03 TH Replaced Above
                  If Trim$(txt$) <> "" Then
                        parsedate txt$, Out$, "8", valid%
                     If valid% And Val(Left$(Out$, 2)) > 0 And Val(Mid$(Out$, 4, 2)) > 0 Then
                        lngNumDays = DateDiff("d", Format(DateValue(Out$), "dd/mm/yyyy"), Format(Now, "dd/mm/yyyy"))
                        'If lngNumDays <= -365 Then    '18Mar03 TH (PBSv4) Altered  (#67146)
                        If lngNumDays >= 365 Then      '    "
                           popmessagecr "#Patient Billing", "Warning, Invalid Date Last Issued (Unoriginal Supply) entered" & crlf & "The prescription has expired. A prescription is only valid for 12 months"
                           QuesSetText index%, ""
                           Billitems$(pos%) = ""
                        '18Mar03 TH (PBSv4) Added block
                        ElseIf lngNumDays < 0 Then
                           popmessagecr "#Patient Billing", "Warning, Invalid Date Last Issued (Unoriginal Supply) entered" & crlf & "The Date Last Issued Cannot be in the Future"
                           QuesSetText index%, ""
                           Billitems$(pos%) = ""
                        '----------------------
                        Else
                           'Check now against original script date if present 18Mar03 TH (PBSv4) Added  (#67146)
                           If Trim$(Billitems$(59)) <> "" Then
                              lngNumDays = DateDiff("d", Format(DateValue(Out$), "dd/mm/yyyy"), Format(Billitems(59), "dd/mm/yyyy"))
                              If lngNumDays > 0 Then
                                 popmessagecr "#Patient Billing", "Warning, Invalid Date Last Issued (Unoriginal Supply) entered" & crlf & "The Date Last Issued Cannot be before the Original Prescription Date"
                                 QuesSetText index%, ""
                                 Billitems$(pos%) = ""
                              Else
                                 QuesSetText index%, Out$
                                 Billitems$(pos%) = Out$
                              End If
                           Else
                           '--------------------------------
                              QuesSetText index%, Out$
                              Billitems$(pos%) = Out$
                              'datePrescriptionWritten$ = out$
                              'originalDate$ = out$ 'Use originaldate, hopefully dateprescriptionwritten will now be obselete
                           End If             '18Mar03 TH (PBSv4) Added
                        End If                                                                                            '   "
                     Else
                        popmessagecr "#Patient Billing", "Warning, Invalid Date Last Issued (Unoriginal Supply) entered"
                        QuesSetText index%, ""
                        Billitems$(pos%) = ""
                     End If
                  End If

   
               End If
               '18Mar03 TH (PBSv4) Added block (#67146)
               Case 90:
                  If Billitems$(53) = "U" Then
                     If Trim$(txt$) = "" Then
                        valid = False
                        popmessagecr "#Patient Billing", "Warning, Unoriginal Supply requires Script Number"
                        QuesSetText index, ""
                     Else
                        Billitems$(pos%) = txt$
                     End If
                  End If
               '--------------------------
               Case 91:
                  If Billitems$(53) = "U" Then
                     If Val(txt$) > NumberOfRepeats() And NumberOfRepeats() > 0 Then
                        valid = False
                        Billitems$(pos) = CStr(m_PBSProduct.MaxRepeats)
                        popmessagecr "#Patient Billing", "The number of times issued exceeds the number repeats allowed for this item"
                        QuesSetText index, ""
                     '19Mar03 TH Removed
                     'ElseIf Val(txt$) <= 0 Then
                     '   valid = False
                     '   Billitems$(pos) = CStr(getfield(snpDrug!maxrepeats))
                     '   popmessagecr "#Patient Billing", "The item must have been issued previously at least once"
                     '   QuesSetText index, ""
                     '------------------
                     Else
                        Billitems$(pos%) = txt$
                     End If
                  End If
            '-------------------------------------------
            '31Mar03 TH (PBSv4)  '01Apr03 TH Removed as now handled as dispensing action
            'Case 92:
            '   If Trim$(txt$) = "" Then txt$ = "N"
            '   Billitems$(pos%) = txt$
            '   If Billitems$(pos%) = "Y" Then
            '      QuesSetEnabled 93, True
            '      QuesSetEnabled 94, True
            '   Else
            '      QuesSetEnabled 93, False
            '      QuesSetEnabled 94, False
            '
            '   End If
            '--------------------
               '02Apr03 TH (PBSv4) Added block
               Case 93:
                  If Billitems$(53) = "X" Then
                     If Trim$(txt$) = "" Then
                        valid = False
                        popmessagecr "#Patient Billing", "Warning, Non-Schedule Allowable Benefit requires Description"
                        QuesSetText index, ""
                     Else
                        Billitems$(pos%) = txt$
                     End If
                  End If
               Case 94:
                  If Billitems$(53) = "X" Then
                     If Val(txt$) = 0 Then
                        valid = False
                        popmessagecr "#Patient Billing", "Warning, Non-Schedule Allowable Benefit requires Quantity"
                        QuesSetText index, ""
                     Else
                        Billitems$(pos%) = txt$
                     End If
                  End If

               '--------------------------

            Case Else:
               Billitems$(pos%) = txt$
         End Select
      End If

End Sub

Function PBSDrugToDispens()
   PBSDrugToDispens = False

'If BillPatient(13, "") And (CheckPBSIssue() Or foundDrugItem) Then
''   If billpatient(13, "") Then                      '04Mar03 TH (PBSv4)Replaced above
''      If (CheckPBSIssue() Or foundDrugitem) Then    '           If not PBS was still doing checks on non existent PBS data
''         PBSDrugToDispens = True
''      End If
''   End If
   If m_blnBillingInitialised = True Then
      If ItemForBilling() And (Val(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "", "BillingType", 0)) = 2) Then PBSDrugToDispens = True
   End If
   
End Function

Function PBSGetBillitem(intIndex As Integer) As String
End Function


Function PBSGetExceptionalQty() As Integer
End Function

Function PBSGetFoundDrugItem() As Integer
   If m_blnBillingInitialised Then
     ''PBSGetFoundDrugItem = gObjBilling.PBSGetFoundDrugItem(d.DrugID)
   End If
End Function

Function PBSIsScreenBigEnough() As Integer
''   PBSIsScreenBigEnough = False
''   If Screen.Width >= 12000 And (Screen.TwipsPerPixelY * 600 < Screen.Height) Then PBSIsScreenBigEnough = True
End Function

Function PBSKeepDate()
   If m_strPBSLastDate <> "" Then
      PBSKeepDate = True
   Else
      PBSKeepDate = False
   End If

End Function

Sub PBSPatientLoad()
End Sub

Sub PBSPatInfoDisplay(ctlDisplay As Control)
End Sub

Function PBSPreIssueChecksOK(ByVal blnReturn As Boolean) As Boolean
'31Jan03 TH (PBSv4) Written as convenient wrapper for all PBS checks prior to launching an issue


Dim blnEscd As Boolean
Dim blnPassed As Boolean
   'If blnPassed = 3 Then               '07Apr03 TH (PBSv4) If Return then dont check repeats
   '   blnPassed = True                 '   "
   'Else                                '   "
   If Not blnReturn Then blnPassed = PBSCheckRepeats()
   'End If                              '   "
   If blnPassed And (Not (TrueFalse(TxtD$(dispdata & "\" & "patmed.ini", "PatientBilling", "N", "PBSLaunchIssueScreen", 0)))) Then blnPassed = AllFieldsCorrect(0)   '18Mar03 TH (PBSv4) Added parmater   '24Jun03 TH Suppress if checking later !
   If blnPassed Then PBSCheckAuthority blnEscd
   If blnEscd Then blnPassed = False
   
   PBSPreIssueChecksOK = blnPassed

End Function



Function PBSReadBillitem(intBillitem As Integer) As String
   PBSReadBillitem = "N"
End Function

Sub PBSRefreshPatDetails(ctlDisplay As Control)
End Sub
Private Function AllFieldsCorrect(intPatientorIssue As Integer) As Boolean
AllFieldsCorrect = True
End Function
Private Sub PBSCheckAuthority(blnEscd As Boolean)
'31Jan03 TH (PBSv4) Written - matches previous check done after issue
'31Jan03 TH (PBSv4) MERGED

Dim intvalid As Integer
Dim strAns As String

   If foundDrugitem And (Not EPItem) Then     ' Remove batchnumber constraint as repeats should also be queried.
      If UCase$(Trim$(m_PBSProduct.RestrictionFlag)) = "A" Then
         intvalid = True
         Do
            strAns = ""
            k.nums = True
            inputwin "Patient Billing", "This is an authority drug." & cr & "Enter authority number to continue" & cr & "or leave blank for a private prescription.", strAns, k
            If k.escd Then
                  blnEscd = True
               Else
                  If Trim$(strAns) <> "" Then
                        ValidateCardNumber strAns, "A", intvalid
                        If intvalid Then
                              ' special authority granted
                              SpecialAuthorityNum$ = strAns
                              PBSItemType$ = "P"
                           End If
                     Else
                        ' private prescription
                        PBSItemType$ = "N"
                        SpecialAuthorityNum$ = ""
                     End If
               End If
         Loop Until (intvalid) Or (blnEscd)
      End If
   End If


End Sub


Sub PBSSetbillitems(intBillitem As Integer, strValue As String)
End Sub

Sub PBSSetNewLabel()
End Sub

Sub PBSSetPBSItemStatus()
End Sub

Function PBSSwitchedOff() As Integer
'19Mar03 TH(PBSv4) Written to explicitly check whether PBS is set up but has been suppressed
            
'   If (Val(txtd(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0)) = 2) And (Not m_blnPBSDispenseOn) Then
'      PBSSwitchedOff = True
'   Else
      PBSSwitchedOff = False
'   End If

End Function

Sub PBSUpdateIssuePanel()
End Sub

Sub ReSubmit()
End Sub
Function PBSCheckRepeats() As Boolean
'31Jan03 TH (PBSv4) Written
Dim intRepeats As Integer
Dim strPBSItemStatus As String
Dim objBilling As Object

   PBSCheckRepeats = True
   If Trim$(m_strBillingComponentURL) <> "" Then
      '''''TH ***99PBS***
      'Set objBilling = CreateObject(m_strBillingComponent)
      'lngRepeats = objBilling.NumberOfRepeats(g_SessionID, gRequestID_Prescription)
      'Set objBilling = Nothing
      '''''TH ***99PBS***
      
      intRepeats = NumberOfRepeats()
      ' check if dispensed all drugs
      '01Jun07 TH If (intRepeats <> -1 And L.batchnumber > intRepeats) Then
      If (intRepeats <> -1 And m_PBSDrugRepeat.NumberOfIssues > intRepeats) Then
      
         ' don't issue anymore for this item
         popmessagecr "#Patient Billing", "You have reached the maximum number of dispensings for this item."
         PBSCheckRepeats = False
      End If
      strPBSItemStatus = PBSItemStatus$
      PBSItemStatus$ = ""
      ItemTypeStatus False, "", "", "", ""
      If PBSItemStatus$ = "O" Then   '    "
            popmessagecr "#Patient Billing", "The previous issue was dispensed in an emergency." & cr & "The prescription must have been received before any" & cr & "more dispensings can take place." & cr & cr & "Select 'Edit HIC Transaction' to receive this prescription."
            PBSCheckRepeats = False
         End If
      PBSItemStatus$ = strPBSItemStatus
   End If
  

End Function

Sub Rx_Callback(index%)
End Sub
Sub Supplier_Callback(index%)
'23Jun05 TH Added
End Sub

Sub RxEditor(a%, b%)
End Sub

Sub SetKeepPBSDefaults(blnSet As Integer)
End Sub

Sub setPBSblnKeepBillitems(blnSetting As Integer)
End Sub

Sub SetPBSNewScript(blnSet As Integer)
End Sub


Sub SetPBSIssueDefaults(blnKeepStatus As Integer)
' intialise various fields in ques scroll before showing to the user
' 10Oct99 SF mods to allow for private dispesnings
'24Nov99 SF for PBS sets the first payment category as the default
'02Dec99 SF for PBS, now doesn't fire "expired message" when expiry date blank
'02Dec99 SF for PBS, now defaults to a general patient type if not known
'16May00 SF now stores the SAapprovalNumber against the Transaction table rather that the Patient table as they differ from item to item
'16May00 SF if nothing in PSC expiry date default to ini file setting
'16May00 SF if controlled drug not explicity set in the pharmac data the set to "N"
'16May00 SF fixed "PermanentHokiangaResident" spelling
'16May00 SF if subsidy card warning do not ask on a private dispensing
'14Jul00 SF added Repeat Dispensing mods
'16Nov00 SF Pharmac variable qty repeat mods
'04Mar02 TH Added Section to allow new Medicare/subnumerate and copayment fields to be set (#MOJ#)
'31Jan03 TH (PBSv4) Added original prescription details field
'                   Added family group number as mandatory field
'                   Changed to default to today if User has not specifically entered a date (Now not prompted automatically)
'                   Added threshold messages for family groups
'31Jan03 TH (PBSv4) MERGED
'25Mar03 TH (PBSv4) Added Error Trapping


Dim dt As DateAndTime   '16May00 SF added
Dim dat$, Out$, repeats%    '08Mar03 TH/ATW Removed valid%,
Dim lines$()      '24Nov99 SF
Dim warningAmount!      '16May00 SF added
Dim found%              '16Nov00 SF added
Dim origPrescriberID$   '16Nov00 SF added
Dim FamilyThresholdAmount!                                             '31Jan03 TH (PBSv4)
Dim FamilywarningAmount!                                               '    "
Dim FamilyScripts!                                                     '    "
Dim strDangerousDrugCode As String, blnDangerousDrug As Integer        '    "
Dim sglOwed As Single, sglOrigDispens As Single, sglValue As Single    '    "
Dim strPBSOriginalApprovalnum As String, strPBSAuthNum As String       '    "
Dim myError$
Dim myErr As Integer
Dim blnPatientSpecificFields As Integer  '01May03 TH Added
Dim objBilling As Object
Dim strXML As String
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMNode
Dim lngCount As Long
Dim OriginalPrescriber As PrescriberStruct



'''On Error GoTo setQuesdefaultsErr

   m_blnPBSPrivateDispensing = False '09Mar03 TH (PBSv4) Added

   If blnKeepStatus = 3 Then              '01May03 TH Added (PBSv4)
      blnKeepStatus = 0                   '    "
      blnPatientSpecificFields = True     '    "
   Else                                   '    "
      blnPatientSpecificFields = False    '    "
   End If                                 '    "
   
   

      '16Nov99 SF added for PBS
      
         
   Screen.MousePointer = STDCURSOR                    '02Dec99 SF added for when messages displayed
   Billitems$(61) = ""                         '31Jan03 TH (PBSv4) Added to allow refresh for drug info panel
   SpecialAuthorityNum$ = ""  '31Jan03 TH (PBSv4) Added
   'billitems$(53) = PBSitemType$                      ' pbs/private
   If Not blnPatientSpecificFields Then       '01May03 TH Added to stop rewrite of fields when only patient defaults required
      If foundDrugitem Then             '31Jan03 TH (PBSv4)
         If PBSItemType$ = "" Then PBSItemType$ = "P"   '31Jan03 TH (PBSv4) Added as default
         Billitems$(53) = PBSItemType$     '     "                                        '01May03 TH Added Clause for Exceptionls  '01May03 TH Reverted to original
         'If (Trim$(UCase$(Billitems$(53))) <> "X" Or (Not blnKeepStatus)) Then Billitems$(53) = PBSItemType$        '    "
      Else                              '     "
         If Not blnKeepStatus Then
            If Trim$(UCase$(Billitems$(53))) <> "X" Then Billitems$(53) = "N"              '     "  '09Mar03 TH (PBSv4) Added if clause '01Apr03 TH Added check on Exceptionals
         Else                               '12Mar03 TH (PBSv4) Had to make more explicit
            If Trim$(UCase$(Billitems$(53))) <> "X" Then Billitems$(53) = "P"            '     "
         End If                             '     "
      End If                            '     "
   End If                                     '01May03 TH
      If Trim$(OriginalDate$) <> "" Then
         Billitems$(59) = OriginalDate$               ' original dispensing date
      'Else                                                       '15Jun01 TH %PBS% Changed to default to today if
      '   BillItems$(59) = datePrescriptionWritten$               '     "     User has not specifically entered a
      'End If
      Else                                                        '     "
         Billitems$(59) = Format(Now, "DD/MM/YYYY")               '     "
      End If                                                      '     "
            
      found = billpatient(18, Out$)                                                                                  '31Jan03 TH (PBSv4) Moved section from
      If Out$ <> "" Then                                                                                             '   "       below because rxer can be altered
         ' use previous prescriber details                                                                        '   "       (as date above)
         origPrescriberID$ = Trim$(gPrescriberID$)                                                                '   "
         ''GetPrescriberDetails True, Out$, 0     'This should be done in the initialise sub                                                                  '   "
         GetPrescriberDetails True, origPrescriberID$, 0, OriginalPrescriber
      End If                                                                                                      '   "
      Billitems$(60) = Trim$(OriginalPrescriber.registrationNumber) & " (" & Trim$(OriginalPrescriber.name) & ")"    '   "
      'If Out$ <> "" Then GetPrescriberDetails True, origPrescriberID$, 0, OriginalPrescriber                                            '   "

      If Not populatedQues% Then
         'ItemTypeStatus False
         
         
         Billitems$(85) = ""   '31Jan03 TH (PBSv4) Temporary Medicare Number
         Billitems$(86) = ""   '                   Temporary Medicare Expiry Date
         If patiententry% Then
            Billitems$(51) = m_PBSPatient.ConcessionNumber
            Billitems$(52) = m_PBSPatient.ConcessionExpiry
            Billitems$(56) = BeneficiaryType$
            Billitems$(58) = safetyNetCard$
            If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "WarnCardExpiries", 0)) Then   '16Nov00 SF added ini files setting whether to warn on expiry
               If PBSItemType$ <> "N" And (Billitems$(56) = "R" Or Billitems$(56) = "C") And (Trim$(Billitems$(52)) <> "" And Val(Right$(Billitems$(52), 4) & Mid$(Billitems$(52), 4, 2) & Left$(Billitems$(52), 2)) < Val(Format$(Now, "yyyymmdd"))) Then     '02Dec99 SF now doesn't fire when expiry date blank
                  popmessagecr "#Patient Billing", "Concession Card Expired" & cr & cr & "Card number:" & TB & Trim$(Billitems$(51)) & cr & "Expiry date:" & TB & Trim$(Billitems$(52))
               End If
            End If                                                                                 '16Nov00 SF added

            Billitems$(57) = m_PBSPatient.SafetyNetNumber
            Billitems$(54) = m_PBSPatient.ThresholdAmount
            Billitems$(54) = Format$(Val(Billitems$(54)), "0.00")
            Billitems$(67) = m_PBSPatient.MedicareNumber     '16Nov00 SF added Medicare Number
            Billitems$(70) = m_PBSPatient.MedicareExpirydate         '06Mar03 TH (PBSv4) Added
            Billitems$(86) = Trim$(m_PBSPatient.TemporaryExpiryDate)  '   "
            Billitems$(69) = Trim$(m_PBSPatient.Subnumerate)          '   "
            Billitems$(72) = m_PBSPatient.RepatriationNumber    ' repat number     '31Jan03 TH (PBSv4)
            Billitems$(73) = m_PBSPatient.RepatriationCardType   ' repat card type  '   "
            Billitems$(68) = Format$(m_PBSPatient.Familygroupnumber)   '31Jan03 TH (PBSv4) Mandatory field
            Billitems$(71) = "" '31Jan03 TH (PBSv4) Clean up
            Billitems$(75) = Format$(m_PBSPatient.Scripts)
            If Val(Billitems$(68)) > 0 Then                                '31Jan03 TH (PBSv4) Family threshold field
               GetfamilyAmounts FamilyThresholdAmount!, FamilyScripts!, Val(Billitems$(68))   '31Jan03 TH (PBSv4) Added script info field  '26Jun01 Added Famnum as param
               Billitems$(74) = Format$(FamilyThresholdAmount!)          '   "
               Billitems$(74) = Format$(Val(Billitems$(74)), "0.00")     '   "
               Billitems$(76) = Format$(FamilyScripts!)                  '   "
            Else                                                         '   "
               Billitems$(74) = "N/A"                                    '   "
               Billitems$(76) = "N/A"                                    '   "
            End If                                                       '   "
            If PBSItemType$ <> "N" Then
               '16Nov00 SF added following to warn if safety net approaching
               If Billitems$(56) = "G" Then
                  warningAmount! = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "GeneralWarning", 0))
                  '31Jan03 TH (PBSv4) TH Family warning here, but does it superceed individual warning or not ? YES
                  If Val(Billitems$(68)) > 0 Then                  'This is better than reading the recordset
                     'Open DB to Sum family costs - sorry
                     ''FamilyThresholdAmount! = GetFamilyThresholdAmount()  'Already got above
                     'famsql$ = "SELECT sum(patbilling.ThresholdAmount) as [FamilyThresholdAmount] FROM PatBilling WHERE PatBilling.FamilyGroupNumber = " & PatInfo!FamilyGroupNumber & ";"
                     'Set Famsnap = PidDB.CreateSnapshot(famsql$)
                     'MsgBox " " & Format$(FamilyThresholdAmount!)  'debug
                     FamilywarningAmount! = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "FamilyGeneralWarning", 0))
                     If FamilywarningAmount! <> 0 Then FamilywarningAmount! = warningAmount!
                     If (FamilywarningAmount! > 0) And (FamilyThresholdAmount! >= FamilywarningAmount!) And (FamilyThresholdAmount! < m_PatFees.GenFamSafety) Then popmessagecr "#Patient Billing", "This family is about to reach the safety net amount." & cr & "They have currently paid " & money(5) & Format$(FamilyThresholdAmount!, "0.00") & " out of " & money(5) & Format$(m_PatFees.GenFamSafety, "0.00") & cr & cr & "The family will soon be entitled to a concession card."
                  Else                                             'Only Use individual warnings if not part of a Family
                  '-------------------------------------
                  If (warningAmount! > 0) And (Val(Billitems$(54)) >= warningAmount!) And (Val(Billitems$(54)) < m_PatFees.GenPatSafety) Then popmessagecr "#Patient Billing", "This patient is about to reach the safety net amount." & cr & "They have currently paid " & money(5) & Format$(Val(Billitems$(54)), "0.00") & " out of " & money(5) & Format$(m_PatFees.GenPatSafety, "0.00") & cr & cr & "The patient will soon be entitled to a concession card."
                  End If             '31Jan03 TH (PBSv4)
               ElseIf Billitems$(56) = "C" Then
                  '31Jan03 TH (PBSv4) Family warning here, but does it superceed individual warning or not ? YES
                  warningAmount! = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "ConcessionWarning", 0))
                  If Val(Billitems$(68)) > 0 Then
                     FamilywarningAmount! = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "FamilyConcessionWarning", 0))
                     If FamilywarningAmount! <> 0 Then FamilywarningAmount! = warningAmount!
                     If (FamilywarningAmount! > 0) And (FamilyThresholdAmount! >= FamilywarningAmount!) And (FamilyThresholdAmount! < m_PatFees.ConFamSafety) Then popmessagecr "#Patient Billing", "This family is about to reach the safety net amount." & cr & "They have currently paid " & money(5) & Format$(FamilyThresholdAmount!, "0.00") & " out of " & money(5) & Format$(m_PatFees.ConFamSafety, "0.00") & cr & cr & "The family will soon be entitled to a safety net card."
                  Else                                             'Only Use individual warnings if not part of a Family
                     '-------------------------------------
                  If (warningAmount! > 0) And (Val(Billitems$(54)) >= warningAmount!) And (Val(Billitems$(54)) < m_PatFees.ConPatSafety) Then popmessagecr "#Patient Billing", "This patient is about to reach the safety net amount." & cr & "They have currently paid " & money(5) & Format$(Val(Billitems$(54)), "0.00") & " out of " & money(5) & Format$(m_PatFees.ConPatSafety, "0.00") & cr & cr & "The patient will soon be entitled to a safety net card."
               End If
            End If
            If Billitems$(56) = "G" Then
               'Check if patient is part of a family
               If Val(Billitems$(68)) > 0 Then
                  If FamilyThresholdAmount! >= m_PatFees.GenFamSafety Then
                     popmessagecr "#Patient Billing", "This family is entitled to a Safety Net Concession Card"
                  End If
               Else
                  If Val(Billitems$(54)) >= m_PatFees.GenPatSafety Then
                     popmessagecr "#Patient Billing", "This patient is entitled to a Safety Net Concession Card"
                  End If
               End If
            ElseIf Billitems$(56) = "C" Then
               If Val(Billitems$(68)) > 0 Then     'Check if patient is part of a family
                  If FamilyThresholdAmount! >= m_PatFees.ConFamSafety Then
                     popmessagecr "#Patient Billing", "This family is entitled to a Safety Net Entitlement Card"
                  End If
               Else
                  If Val(Billitems$(54)) >= m_PatFees.ConPatSafety Then
                     popmessagecr "#Patient Billing", "This patient is entitled to a Safety Net Entitlement Card"
                  End If
               End If
            End If
            '----------------------------------------------------------------
         End If
      Else
         'defaults
         Billitems$(51) = ""     ' card number
         Billitems$(52) = ""     ' card expiry
         Billitems$(54) = "0"    ' amount paid so far
         'BillItems$(56) = ""    ' beneficiary type     '02Dec99 SF replaced
         Billitems$(56) = "G"    ' beneficiary type     '02Dec99 SF default to a general patient
         '16Nov00 SF added
         Billitems$(67) = ""
         Billitems$(72) = ""     ' repat number     '31Jan03 TH (PBSv4)
         Billitems$(73) = ""     ' repat card type  '  "
''         THis must be handled outside of the OCX
''         PatInfo.AddNew
''         PatInfo!PatRecNo = pid.recno
''         PatInfo.Update
''         PatInfo.Close
''         sql$ = "SELECT * FROM PatBilling WHERE PatBilling.PatRecNo = '" & Trim$(pid.recno) & "';"                      '16Nov00 SF
''         Set PatInfo = PIDdb.CreateDynaset(sql$)
         patiententry = True
         '16Nov00 SF -----
      End If
   End If
         

   ' setup number of repeat for this item
   repeats = NumberOfRepeats()
   If repeats <> -1 Then
      ' existing item
      Billitems$(11) = Format$(repeats)
   Else
      ' new item so use pbs max
      If foundDrugitem Then
         Billitems$(11) = Format$(m_PBSProduct.MaxRepeats)
      Else
         If blnKeepStatus Then                            '17Mar03 TH (PBSv4) Added
            Billitems$(11) = Format$(m_PBSProduct.MaxRepeats)  '    "
         Else                                             '    "
            Billitems$(11) = ""
         End If                                           '    "
      End If
   End If

   '31Jan03 TH (PBSv4) Added for DD Repeat Intervals
   If Not EPItem Then
      strDangerousDrugCode = Trim$(UCase$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "DangerousDrugCode", 0)))
      If Trim$(strDangerousDrugCode) <> "" Then
         If InStr(strDangerousDrugCode, ".") > 0 Then
            If Trim$(UCase$(Left$(d.bnf, 8))) = strDangerousDrugCode Then blnDangerousDrug = True
         Else
            If Trim$(UCase$(d.therapcode)) = strDangerousDrugCode Then blnDangerousDrug = True
         End If
      End If
   End If

   If blnDangerousDrug Then
      Billitems$(77) = Str$(m_intRepeatInterval)
   Else
      Billitems$(77) = "20"
   End If
   '31Jan03 TH (PBSv4) ------------------
   If Not blnPatientSpecificFields Then       '01May03 TH Added to stop rewrite of fields when only patient defaults required
      '23Feb03 TH (PBSv4) Added block
      On Error Resume Next
      ''''18Mar03 TH (PBSv4) Added read of repeats to get unoriginal info (if any) as default.
      'sql$ = "SELECT * FROM drugrepeats WHERE rxnumber = " & Format$(L.prescriptionid) & ";"
      'Set snap = Patdb.CreateSnapshot(sql$)
      'If Not snap.EOF Then
      '''''TH ***99PBS***
      'Set objBilling = CreateObject(m_strBillingComponent)
      'strXML = objBilling.pPBSTransactionbyPrescriptionIDandDispensingNumberXML(g_SessionID, L.prescriptionid, L.BatchNumber) ', gDispSite, strPBSTtype)
      'Set objBilling = Nothing
      '''''TH ***99PBS***
      Set xmlDoc = New MSXML2.DOMDocument
      If xmlDoc.loadXML(strXML) Then
         If InStr(LCase(strXML), "pbsdrugrepeat") > 0 Then
            Set xmlnode = xmlDoc.selectSingleNode("xml\PBSDrugRepeat")
''            Billitems$(88) = Trim$(GetField(snap!ApprovalNumber))
''            Billitems$(89) = Trim$(GetField(snap!originalLastIssuedDate))
''            Billitems$(91) = Trim$(GetField(snap!originalTimesIssued))
''            Billitems$(90) = Trim$(GetField(snap!originalscriptnumber))
            Billitems$(88) = Trim$(xmlDoc.Attributes("ApprovalNumber").Text)
            Billitems$(89) = Trim$(xmlDoc.Attributes("originalLastIssuedDate").Text)
            Billitems$(91) = Trim$(xmlDoc.Attributes("originalTimesIssued").Text)
            Billitems$(90) = Trim$(xmlDoc.Attributes("originalscriptnumber").Text)
            '31Mar03 TH (PBSv4) Added for new exceptional items
            'If (Trim$(getfield(snap!ExcepDescription)) <> "") And (Val(getfield(snap!originalTimesIssued)) <> 0) Then '01May03 TH Replaced
            If (Trim$(xmlDoc.Attributes("ExcepDescription").Text) <> "") And (Val(xmlDoc.Attributes("ExcepQty").Text) <> 0) Then            '    "
               'Billitems$(92) = "Y"  '01Apr03 TH Removed
               Billitems$(93) = Trim$(xmlDoc.Attributes("ExcepDescription").Text)
               'Billitems$(94) = Format$((getfield(snap!originalTimesIssued)))  '01May03 TH Replaced
               Billitems$(94) = Format$(xmlDoc.Attributes("ExcepQty").Text)             '    "
               Billitems$(53) = "X" '01May03 TH Added as if exceptional description exists then it must be an X type
            Else
               'Billitems$(92) = "N"  '01Apr03 TH Removed
               Billitems$(93) = ""
               Billitems$(94) = "0"
            End If
            Set xmlnode = Nothing
            '----------------------
         'Else
               '----------------------------
         'TH 11Sep06 THIS NEEDS CHECKING !!!!!!!
           '    Billitems$(88) = Trim$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "ApprovalNumber", 0))
           '    Billitems$(89) = "" 'datePrescriptionWritten$    '24Feb03 TH (PBSv4) Altered
           '    'If Trim$(TimesIssued$) = "" Then TimesIssued$ = CStr(getfield(snpDrug!MaxRepeats)) '18Mar03 TH (PBSv4) Removed
           ''    'If foundDrugItem Then                                                              '    "
           '    '   BillItems$(91) = TimesIssued$                                                   '    "
           '    'Else                                                                               '    "
           '    '   BillItems$(91) = "0"                                                            '    "
           '    'End If                                                                             '    "
           '    Billitems$(91) = ""  '18Mar03 TH (PBSv4) Now the default for this is always blank (#67171) Replaced Above
           '    Billitems$(90) = ""
           '    '31Mar03 TH (PBSv4) Added for new exceptional items
           '    'Billitems$(92) = "N"  '01Apr03 TH Removed
           '    Billitems$(93) = ""
           '    Billitems$(94) = "0"
                     '--------------------
                  
         '18Mar03 TH (PBSv4)
         End If
      End If
     ' snap.Close: Set snap = Nothing
      'On Error GoTo 0
      '''''On Error GoTo setQuesdefaultsErr  '28Mar03 TH/ATW Changed
   '-----------------------------
   End If                               '01May03 TH Added
         
   '16Nov00 SF get previous payment type
   found = False
''   sql$ = "SELECT * FROM transactions WHERE prescriptionid = " & Format$(L.prescriptionid) & " AND dispensingnumber = " & Format$(L.batchnumber) & ";"
''   Set snap = Patdb.CreateSnapshot(sql$)
   '''''TH ***99PBS***
   'Set objBilling = CreateObject(m_strBillingComponent)
   'strXML = objBilling.pPBSTransactionbyPrescriptionIDandDispensingNumberXML(g_SessionID, L.prescriptionid, L.BatchNumber) ', gDispSite, strPBSTtype)
   'Set objBilling = Nothing
   '''''TH ***99PBS***
   Set xmlDoc = New MSXML2.DOMDocument
   If xmlDoc.loadXML(strXML) Then
      If InStr(LCase(strXML), "pbsTransaction") > 0 Then
         Set xmlnode = xmlDoc.selectSingleNode("xml\PBSTransaction")
         Billitems$(62) = xmlnode.Attributes("PaymentCategory").Text
         Billitems$(71) = xmlnode.Attributes("original").Text
         Set xmlnode = Nothing
      Else
         '16Nov00 SF do as before
         '24Nov99 SF
         ReDim lines$(3)
         dat$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "1", 0)    ' use the first entry as the default
         deflines dat$, lines$(), ",", 1, 0
         Billitems$(62) = Trim$(lines$(1))
         Billitems$(71) = ""      '31Jan03 TH (PBSv4)
         '24Nov99 SF -----
      End If
   End If
   'snap.Close: Set snap = Nothing
   Set xmlDoc = Nothing
   Billitems$(63) = "N"                   ' default to no receipt being printed
   '16Nov00 SF -----
   '16Nov00 SF added to warn the user if a previous transaction has been edited
   If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "PrevTransEditWarning", 0)) Then
      On Error Resume Next
      'sql$ = "SELECT * FROM editedTransactions WHERE prescriptionid = " & Format$(L.prescriptionid) & ";"
      'Set snap = Patdb.CreateSnapshot(sql$)
      '''''TH ***99PBS***
      'Set objBilling = CreateObject(m_strBillingComponent)
      'lngCount = objBilling.PBSEditedTransactionCountbyPrescriptionID(g_SessionID, L.prescriptionid) ', gDispSite, strPBSTtype)
      'Set objBilling = Nothing
      '''''TH ***99PBS***
      'If Not snap.EOF Then
      If lngCount > 0 Then
         popmessagecr "#Patient Billing", "A previous transaction to HIC for this prescription has been edited, please check that" & cr & "the following details are still valid and amend if necessary before dispensing."
      End If
      'snap.Close: Set snap = Nothing
      On Error GoTo 0
   End If
   '16Nov00 SF -----

   '16Nov99 SF -----
   '31Jan03 TH (PBSv4) Added for new PBS on screen views -
   If repeats% = -1 Then
      Billitems$(81) = "0"
   Else
      sglOwed = NumberOfOwes!(sglOrigDispens)
      ItemTypeStatus False, "", "", "", ""  '31Jan03 TH (PBSv4) Added extra params
      If PBSItemType$ = "D" Then
         sglValue = 0
      Else
         '01Jun07 TH sglValue = (L.batchnumber * sglOrigDispens)
         sglValue = (m_PBSDrugRepeat.NumberOfIssues * sglOrigDispens)
      End If
      Billitems$(81) = Format$(sglValue) & " " & LCase(Trim$(d.PrintformV))
   End If
   ItemTypeStatus False, "", strPBSAuthNum, strPBSOriginalApprovalnum, ""  '31Jan03 TH (PBSv4) Added parameter
   Select Case PBSItemType$
      Case "P": Billitems$(82) = "PBS"
      Case "N": Billitems$(82) = "Private"
   End Select
   Select Case PBSItemStatus$
      Case "D": Billitems$(83) = "Item was deferred"
      Case "O": Billitems$(83) = "Emergency Dispense (Rx owed)"
      Case "R": Billitems$(83) = "Regulation 24"
      Case Else:
            If Trim$(strPBSOriginalApprovalnum) = "" Then                           '   "
               Billitems$(83) = "Normal Dispensing"
            Else
               Billitems$(83) = "Normal Dispensing (Unoriginal)"
            End If
   End Select
      
   populatedQues% = True

setQuesdefaultsEnd:
   On Error Resume Next
   On Error GoTo 0
   Exit Sub
setQuesdefaultsErr:
   myError$ = Error$
   myErr = Err
   popmessagecr ".Patient Billing", "Error in procedure: setQuesdefaults" & cr & cr & "Error: " & myError$ & cr & "Error number: " & Format$(myErr)
   Resume setQuesdefaultsEnd


End Sub



Function BillPatDispensQty%(stockLevel!, DispensQty!, negorpos%, escd%)
'15Feb13 XN  Replace WLabel.LastDate string with WLabel.lastSavedDateTime date (40210)

Dim SQL$, drugName$, txt$, ans$, lastDispensQty!, repeats%
Dim dat$, numDays&   '16Nov99 SF added for PBS    '08Mar03 TH/ATW Remove status$
Dim snap As Snapshot         '*16May00 SF added to lookup original prescriber
Dim origdat$                                                                                                '31Jan03 TH PBS ver 3
Dim strDangerousDrugCode As String, blnDangerousDrug As Integer, intRepeatDays As Integer, strMsg As String '   "



   If isPBS() Then   '25Mar03 TH(PBSv4) Fencepost added
      BillPatDispensQty = True
      toDispens! = Qty!
      If negorpos = 1 Then    ' only check on an issue
         repeats = NumberOfRepeats()
         ' check if dispensed all drugs
         '01Jun07 TH If (repeats% <> -1 And L.batchnumber > repeats) Then
         If (repeats% <> -1 And m_PBSDrugRepeat.NumberOfIssues > repeats) Then
            popmessagecr "#Patient Billing", "You have reached the maximum number of dispensings for this item."
            BillPatDispensQty = True
            escd = True
         '01Jun07 TH ElseIf (L.batchnumber > 0 And PBSItemStatus$ <> "O") Or (L.batchnumber = 0 And Billitems$(53) = "U") Then
         ElseIf (m_PBSDrugRepeat.NumberOfIssues > 0 And PBSItemStatus$ <> "O") Or (m_PBSDrugRepeat.NumberOfIssues = 0 And Billitems$(53) = "U") Then
            ' check if correct number of days ellapsed before it is valid to dispens another repeat
            '31Jan03 TH (PBSv4) use original rx date here if available - not labeldate
            ItemTypeStatus False, origdat$, "", "", ""                           '31Jan03 TH (PBSv4) Added extra params
            parsedate LastSavedDateTimeToDateTime(L.lastSavedDateTime), dat$, "1", 0 '40210 XN 15Feb13 use proper date\time for WLabel      parsedate L.lastdate, dat$, "1", 0           '06Mar03 TH Replaced (PBSv4)
            If Billitems$(53) = "U" Then dat$ = Billitems$(89)   '18Mar03 TH (PBSv4) Added
            datetodays dat$, Format$(Now, "dd/mm/yyyy"), numDays&, 0, "", 0
            ' 5 or more repeats for an item and the repeat should only be issued after 20 days of the previous issue
            '31Jan03 TH (PBSv4) Added for DD Repeat Intervals
            If Not EPItem Then
               strDangerousDrugCode = Trim$(UCase$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "DangerousDrugCode", 0)))
               If Trim$(strDangerousDrugCode) <> "" Then
                  If InStr(strDangerousDrugCode, ".") > 0 Then
                     If Trim$(UCase$(Left$(d.bnf, 8))) = strDangerousDrugCode Then blnDangerousDrug = True
                  Else
                     If Trim$(UCase$(d.therapcode)) = strDangerousDrugCode Then blnDangerousDrug = True
                  End If
               End If
            End If
                          
            ans$ = "N"          '31Jan03 TH (PBSv4)
            If repeats >= 5 Then
               '31Jan03 TH (PBSv4)  Added bloc
               If blnDangerousDrug Then
                  intRepeatDays = m_intRepeatInterval + 1
               Else
                  intRepeatDays = 21
               End If
               'If intRepeatDays = 21 Then    '08Mar03 TH/ATW replaced to always use the *authority* msg (even if set to 20 days for dangerous drugs)
               If Not blnDangerousDrug Then
                  strMsg = "You should allow 20 clear days from " & dat$ & cr & "before dispensing another repeat." & cr & cr & "If you need to dispense this repeat now" & cr & "stamp 'Immediate Supply' on the authority form." & cr & cr & "Do you want to continue with this issue?"
               Else
                  strMsg = "The Repeat interval has been specified as " & Format$(m_intRepeatInterval) & "days." & cr & "You should allow " & Format$(m_intRepeatInterval) & " clear days from " & dat$ & cr & "before dispensing another repeat." & cr & cr & "If you need to dispense this repeat now" & cr & "stamp 'Immediate Supply' on the authority form." & cr & cr & "Do you want to continue with this issue?"
               End If
               '31Jan03 TH (PBSv4) ------------
               'If numDays& < 21 Then                 '31Jan03 TH (PBSv4)
               If numDays& < intRepeatDays Then       '   "
                  ' give the user the option to override
                  askwin "?Patient Billing", strMsg, ans$, k
                  If ans$ = "N" Or k.escd Then
                     BillPatDispensQty = True
                     escd = True
                  Else
                     dispensStatus$ = "I"    ' set to immediate supply
                  End If
               End If
            ' less than 5 repeats for an item and the repeat should only be issued after 4 days of the previous issue
            Else
               If blnDangerousDrug Then                          '31Jan03 TH (PBSv4) Added
                  intRepeatDays = m_intRepeatInterval + 1     '    "
               Else                                           '    "
                  intRepeatDays = 5                           '    "
               End If                                         '    "
               If intRepeatDays = 5 Then
                  strMsg = "You should allow 4 clear days from " & dat$ & cr & "before dispensing another repeat." & cr & cr & "If you need to dispense this repeat now" & cr & "stamp 'Immediate Supply' on the authority form." & cr & cr & "Do you want to continue with this issue?"
               Else
                  strMsg = "The Repeat interval has been specified as " & Format$(m_intRepeatInterval) & "days." & cr & "You should allow " & Format$(m_intRepeatInterval) & " clear days from " & dat$ & cr & "before dispensing another repeat." & cr & cr & "If you need to dispense this repeat now" & cr & "stamp 'Immediate Supply' on the authority form." & cr & cr & "Do you want to continue with this issue?"
               End If
                              
               If numDays& < intRepeatDays Then  '     "
                  ' give the user the option to override
                  askwin "?Patient Billing", strMsg, ans$, k  '31Jan03 TH (PBSv4) Replaced param with strMsg
                  If ans$ = "N" Or k.escd Then
                     BillPatDispensQty = True
                     escd = True
                  Else
                     dispensStatus$ = "I"    ' set to immediate supply
                  End If
               End If
            End If
         End If
      End If
   End If    '25Mar03 TH (PBSv4) Added
      

End Function

Function PrivateBilling() As Boolean

   If (Not foundDrugitem) And Billitems$(53) = "N" Then
      PrivateBilling = True
   Else
      PrivateBilling = False
   End If

End Function
Sub billingSelectItem(ByRef intFound As Integer, ByRef strAbort As String)
'08Aug06 TH New billing routine to be used as general billing Product selection routine
Dim lngRes As Long
Dim intEscd As Integer

   'MsgBox "In BillingSelectItem" 'PBSDEBUG
   If m_blnBillingInitialised And m_blnPBSDispenseOn Then '29May07 TH Added check
      ''If Not billpatient(15, "1") Then       'Select the correct PBS row using the current DrugID and the type for the Rxer
      
      'If Trim$(txtUC("TxtPrompt").Text) = "A" Then '31Jan03 TH (PBSv4) Added
      'We cant test the user control here, but Amend is no longer an option
      'If we need to test then we will probably do it at level of request /repeats table
      'If we are amending an existing label then
      '   pbstxt = "AMEND"
      'Else
      '   pbstxt = ""
      'End If
      PBScode$ = ""
      manuCode$ = ""
      'MsgBox "past checks 1" 'PBSDEBUG
      If ProductHasFormula() Then
         AttachManuPBScode intEscd
      Else
         ''AttachManuPBScode intEscd '24Aug06 TH DEBUG MUST REMOVE !!!
         '$$$TH Need to get the prescriber type here
         'MsgBox "about to access Aelect PBS Item" 'PBSDEBUG
         SelectPBSitem intEscd, m_FoundDrugitem, "G"
         If (Not m_FoundDrugitem) And (Not intEscd) Then  '19Mar03 TH (PBSv4) Added extra clause on escd  (#67236)
            PBSItemType$ = "N"
            popmessagecr "#Patient Billing", "This is not currently a PBS subsidised item." & cr & "Any dispensings will have to be private."
         End If
      End If
      
      'If PBSGetFoundDrugItem() Then                          'Dont warn if not on schedule
      If m_FoundDrugitem Then
         intFound = True
         If billpatient(12, "") Then                    '    "              Pass in Text
            ' user cancelled out so abort the issue
            intFound = False
            strAbort = "Y"
         End If
      End If
   Else
      'intFound = False
      'strAbort = "Y"
   End If
   

End Sub
Public Sub SelectPBSitem(ByRef escd As Integer, ByRef pbsItemsfound As Integer, ByVal strPBSType As String)


Dim dcopy As DrugParameters                                 '16Nov00 SF added
Dim Continue%, LineChosen%, lngDrugFound As Long  '16Nov00 SF added  '01Jun02 All/CKJ was found% '08Mar03 TH/ATW Removed  x%, numSolventsInList%,
Dim Status$, drugName$, nsvList$, txt$, Out$          '16Nov00 SF added
Dim Solventmsg$        '    "
Dim myError$
Dim myErr As Integer
Dim rsPBSDrugs As ADODB.Recordset
Dim strParams As String
Dim strPBSTtype As String
Dim strXML As String
'Dim d As DrugParameters
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMNode
Dim xmlNSVCodeNode As MSXML2.IXMLDOMNode
Dim objBilling As Object
Dim strAns As String
Dim strNSVCode As String
Dim strPBSProductXML As String
Dim xmlProductdoc As MSXML2.DOMDocument
Dim HttpRequest As WinHttpRequest

On Error GoTo SelectPBSitemErr

   solventPBScode$ = ""
   EPItem = False
   Status$ = ""
   escd = False
   drugName$ = Trim$(d.LabelDescription)	' drugName$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
   
   strXML = BillingInterface(g_SessionID, "GetPBSProductbyDrugID", "", d.DrugID)
   
   Set xmlDoc = New MSXML2.DOMDocument
   If InStr(LCase(strXML), "pbsproduct") > 0 Then
      If xmlDoc.loadXML(strXML) Then
         pbsItemsfound = True
         Do
            Unload LstBoxFrm
            LstBoxFrm.LstBox.Clear
            LstBoxFrm.Caption = "Patient Billing"
            LstBoxFrm.lblTitle = cr & "Select the correct PBS code for: " & drugName$ & " (" & Trim$(d.tradename) & ")" & cr    '17Nov99 SF/CKJ Added preceding cr
            LstBoxFrm.lblTitle = LstBoxFrm.lblTitle & cr & "Highlight and right click on selected item to see brand substitutute or to cost the item" & cr
            LstBoxFrm.lblHead = "PBS Code   " & TB & "Brand" & Space$(30) & TB & "NSV Code   " & TB & "Max Qty" & TB & "Max Rpts" & TB & "Drug Type" & TB & "Restrictions" & TB & "Premium    " & TB & "Disp for Max Qty" & TB & "Max Safety Net"  '31Jan03 TH (PBSv4) More space for brand name
            Continue = False
            If Status$ = "<DISPLAY BRAND SUBSTITUTES>" Then
               LstBoxFrm.LstBox.AddItem "<DISPLAY ORIGINAL CHOICE>"
            Else
               LstBoxFrm.LstBox.AddItem "<DISPLAY BRAND SUBSTITUTES>"
            End If
            nsvList$ = ""
            If InStr(LCase$(strXML), "pbsproduct") > 0 Then
               'Former ordering : General
               '                  General  Authority
               '                  Repatriation
               '                  Repatriation Authority
               '                  Dental
               '                  Drs Bag
               '                  Anything else (notably HSD Items)
               'order based on DrugTypeCode and RestrictionFlag
               
               Set xmlNodeList = xmlDoc.selectNodes("xml/PBSProduct")
               For Each xmlnode In xmlNodeList
                   ' General
                   LstBoxFrm.LstBox.AddItem CreatePBSLine(xmlnode, 0)
                   LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = Val(xmlnode.Attributes.getNamedItem("PBSProductID").Text)
               Next
               Set xmlNodeList = Nothing
            End If
            popmenu 0, "", 0, 0
            popmenu 1, "&Show brand substitutes for the highlighted item", True, False
            popmenu 1, "&Cost of dispensing for the highlighted item", True, False
            'popmenu 1, "&Edit NSVCode Link for the highlighted item", True, False   '31Jan03 TH (PBSv4)
            
            LstBoxShow
   
            popmenu 0, "", 0, 0
            Out$ = Trim$(LstBoxFrm.LstBox.Tag)           ' get option off user from popup menu
            If Trim$(LstBoxFrm.Tag) = "" Then
               ' user cancelled
               escd = True
               foundDrugitem = False '31Jan03 TH (PBSv4) Added
               Set xmlDoc = Nothing
            ElseIf Trim$(LstBoxFrm.Tag) = "<DISPLAY BRAND SUBSTITUTES>" Then
               Set xmlDoc = Nothing
               
               strXML = BillingInterface(g_SessionID, "GetPBSProductbyDrugIDforBrandSubstitution", "", d.DrugID)
               Set xmlDoc = New MSXML2.DOMDocument
               If Not xmlDoc.loadXML(strXML) Then
                  'Problem - raise error and back out
               End If
               Status$ = "<DISPLAY BRAND SUBSTITUTES>"
               Continue = True
            ElseIf Trim$(LstBoxFrm.Tag) = "<DISPLAY ORIGINAL CHOICE>" Then
               Set xmlDoc = Nothing
               strXML = BillingInterface(g_SessionID, "GetPBSProductbyDrugID", "", d.DrugID)
               Set xmlDoc = New MSXML2.DOMDocument
               If Not xmlDoc.loadXML(strXML) Then
                  'Problem - raise error and back out
               End If
               Set objBilling = Nothing
              
               Status$ = "<DISPLAY ORIGINAL CHOICE>"
               Continue = True
            Else
               LineChosen = LstBoxFrm.LstBox.ListIndex
                        
               'Now get the item and fill the type
               '''TH 99PBS
               If (Out$ = "2") And ((Trim$(LstBoxFrm.Tag) <> "<DISPLAY BRAND SUBSTITUTES>") And (Trim$(LstBoxFrm.Tag) <> "<DISPLAY ORIGINAL CHOICE>")) Then
                  CostOfItem 0, LstBoxFrm.LstBox.ItemData(LineChosen) 'm_PBSProduct.PBSProductID         '02Apr03 TH (PBSv4) Replaced
                  Continue = True
               End If
               If (Out$ = "3") And ((Trim$(LstBoxFrm.Tag) <> "<DISPLAY BRAND SUBSTITUTES>") And (Trim$(LstBoxFrm.Tag) <> "<DISPLAY ORIGINAL CHOICE>")) Then  '27Jun01 TH %PBS%
                  popmessagecr "Patient Billing", "This functionality is not available in this version"
                  Continue = True
               End If
               If Not Continue Then
                  Set xmlDoc = Nothing
                  'Product is selected
                  strPBSProductXML = BillingInterface(g_SessionID, "GetPBSProductbyPBSProductID", "", LstBoxFrm.LstBox.ItemData(LineChosen))
                  Set xmlProductdoc = New MSXML2.DOMDocument
                  If xmlProductdoc.loadXML(strPBSProductXML) Then
                     'Get the node, Put it in
                     Set xmlNodeList = xmlProductdoc.selectNodes("xml/PBSProduct")
                     For Each xmlnode In xmlNodeList 'Should only be one
                        CastXMLToPBSProduct xmlnode, m_PBSProduct
                        strNSVCode = Trim$(xmlnode.Attributes.getNamedItem("NSVCode").Text)
                     Next
                     Set xmlNodeList = Nothing
                     foundDrugitem = True '29May07 TH Added
                  End If
                  Set xmlProductdoc = Nothing
               End If
            End If
         Loop Until Not Continue
            
         If Not escd Then
            If Not m_PBSProduct.PBSSubsidised Then
               escd = True
               popmessagecr "#Patient Billing", "This item is no longer PBS subsidised" & Space$(20)
            End If
         Else
            foundDrugitem = False
            pbsItemsfound = False
         End If
            
         If Not escd Then
            If Trim$(UCase$(m_PBSProduct.DrugTypeCode)) = "DB" Then
               If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "DrsBagWarning", 0)) Then
                  popmsg "#Patient Billing", "Dr's Bag Item Selected. Are you sure this is correct ?", MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, strAns, escd
                  If strAns <> "Y" Then
                     escd = True
                  End If
               End If
            End If
         End If
         
         If Not escd Then                                         '17Nov99 SF/CKJ added - avoids object not set
            If m_PBSProduct.SolventRequired And TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "DisplaySolventMsg", 0)) Then
               Solventmsg$ = "Must add solvent to the PMR if stock usage" & crlf & "tracking of solvent is required."
               Solventmsg$ = Solventmsg$ & crlf & crlf & " The PBS claim will already include details for the solvent."
               Solventmsg$ = TxtD(dispdata$ & BillIniFile$, "PBS", Solventmsg$, "SolventMsg", 0)
               popmessagecr "#Patient Billing", Solventmsg$
            End If
            If Not escd Then
               If (Trim$(m_Prescriber.prescribertype) = "DT") And (UCase$(Trim$(m_PBSProduct.DrugTypeCode)) <> "DT") Then
                  txt$ = "The current prescriber is a dentist." & cr
                  txt$ = txt$ & "The item selected to dispense is not from the dental preparations list." & cr & cr
                  txt$ = txt$ & "Do you want to continue ? If You do then the prescription will be done" & cr & "as a private dispensing"
                  strAns = "N"
                  askwin "?Patient Billing", txt$, strAns, k
                  If strAns = "Y" Then
                     PBSItemType$ = "N"
                  Else
                     escd = True
                  End If
               End If
               If (Trim$(m_Prescriber.prescribertype) <> "DT") And (UCase$(Trim$(m_PBSProduct.DrugTypeCode)) = "DT") Then
                  txt$ = "The current prescriber is not a Dentist." & cr
                  txt$ = txt$ & "The item selected to dispense is from the dental preparations list." & cr & cr
                  txt$ = txt$ & "Do you want to continue?"
                  strAns = "N"
                  askwin "?Patient Billing", txt$, strAns, k
                  If (k.escd) Or (strAns = "N") Then escd = True
               End If
                                          
               If Not escd Then
                  PBScode$ = Trim$(m_PBSProduct.PBScode)
                  manuCode$ = Trim$(m_PBSProduct.ManufacturersCode)
                  If d.SisCode <> UCase$(strNSVCode) Then
                     If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "AutoChangeNSVcode", 0)) Then
                        Continue = True
                     Else
                        Continue = True
                        BlankWProduct dcopy
                        dcopy.SisCode = UCase$(strNSVCode)
                        getdrug dcopy, 0, lngDrugFound, False
                        If (lngDrugFound = 0) Or (dcopy.inuse = "N") Then
                           If lngDrugFound = 0 Then
                              txt$ = "Item not found in the product file, cannot replace"
                              Continue = False
                           ElseIf dcopy.inuse = "N" Then
                              txt$ = "Item set to not in use in the product file, cannot replace"
                              Continue = False
                           End If
                           popmessagecr "#Patient Billing", txt$
                        End If
   
                        If Continue Then
                           Out$ = Trim$(dcopy.LabelDescription)  ' Out$ = Trim$(dcopy.Description) XN 4Jun15 98073 New local stores description
                           plingparse Out$, "!"
                           txt$ = "The current item selected from the product file is:" & cr & cr
                           txt$ = txt$ & d.SisCode & " " & drugName$ & " (" & Trim$(d.tradename) & ")" & cr & cr & cr
                           txt$ = txt$ & "You have selected to brand substitute it with the following item:" & cr & cr
                           txt$ = txt$ & dcopy.SisCode & " " & Out$ & " (" & Trim$(dcopy.tradename) & ")" & cr
                           popmessagecr "#Patient Billing", txt$
                        Else
                           escd = True
                        End If
                     End If
                     If (Continue) Then
                        ''''THIS NEEDS PASSING BACK TO THE CALLING DISPENSE.OCX !!!!! Not anymore my son !
                        BlankWProduct d
                        d.SisCode = UCase$(strNSVCode)
                        getdrug d, 0, lngDrugFound, False
                        If lngDrugFound > 0 Then
   ''                                             l.SisCode = d.SisCode
   ''                                             createlabel 1
   ''                                             memorytolabel
                        Else
                           escd = True
                           popmessagecr "#Patient Billing", "NSV Code: " & d.SisCode & " not found"
                           pbsItemsfound = False
                           m_blnPBSDispenseOn = False
                        End If
                     End If
                     If k.escd Then
                        escd = True
                        foundDrugitem = False
                        pbsItemsfound = False
                        m_blnPBSDispenseOn = False
                     End If
                  End If
               End If
            End If
         End If
         Unload LstBoxFrm
      Else
         pbsItemsfound = False
         m_blnPBSDispenseOn = False
      End If
   Else
      pbsItemsfound = False
      m_blnPBSDispenseOn = False
   End If

SelectPBSitemEnd:
   On Error Resume Next
   On Error GoTo 0
   Exit Sub
SelectPBSitemErr:
   myError$ = Error$
   myErr = Err
   popmessagecr ".Patient Billing", "Error in procedure: SelectPBSitem" & cr & cr & "Error: " & myError$ & cr & "Error number: " & Format$(myErr)
   Resume SelectPBSitemEnd

End Sub
Private Sub AttachManuPBScode(escd%)
'16Nov00 SF added for PBS Extemporaneously Prepared(EP) items
'        This procedure gives the user a picking list of EP items available and records the chosen one against the PBScode


ReDim lines$(2)
'Dim SQL$, tmp$  '08Mar03 TH/ATW Removed, ans$
'Dim x%  '08Mar03 TH/ATW Removed  , valid%
Dim strTemp As String
'Dim rsEPItems As ADODB.Recordset
Dim strXML As String
'Dim d As DrugParameters
Dim blnNoEPItems As Boolean
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlNodeList As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMNode
Dim xmlNSVCodeNode As MSXML2.IXMLDOMNode
Dim objBilling As Object

   
   On Error GoTo AttachPBScodeErr
   
   ' defaults
   PBSItemType$ = "P"
   PBScode$ = ""
   manuCode$ = ""
   escd = False
      
    ' get a list of all EP items available
'''   sql$ = "SELECT * FROM EPaverageprices ORDER BY description;"
'''   Set snpDrug = Patdb.CreateSnapshot(sql$)
   blnNoEPItems = True
   'Set rsEPItems = gTransport.ExecuteSelectSP(g_SessionID, "pPBSEPAveragePricesSelectAll", "")
   'TH 99PBS
   'Set objBilling = CreateObject(m_strBillingComponent)
   'strXML = objBilling.PBSEPAveragePricesSelect(g_SessionID)
   'Set objBilling = Nothing
   
   strXML = BillingInterface(g_SessionID, "GetPBSEPAveragePrices", "", 0)
   
   Set xmlDoc = New MSXML2.DOMDocument
   If xmlDoc.loadXML(strXML) Then
   
      If InStr(LCase$(strXML), "pbsepaverageprices") > 0 Then
         blnNoEPItems = False
         Unload LstBoxFrm
         LstBoxFrm.Caption = "Patient Billing"
         LstBoxFrm.lblTitle.Caption = crlf & "Select the EP PBS code." & crlf
         LstBoxFrm.lblHead.Caption = "PBS Code    " & TB & "Max Qty" & TB & "Max Repeats  " & TB & "Description" & Space$(100)
''         Do While Not rsEPItems.EOF
''            LstBoxFrm.LstBox.AddItem Trim$(GetField(rsEPItems!PBSCode)) & TB & Trim$(GetField(rsEPItems!maxqty)) & Trim$(GetField(rsEPItems!issueunit)) & TB & Trim$(GetField(rsEPItems!MaxRepeats)) & TB & Trim$(GetField(rsEPItems!Description)) & TB
''            rsEPItems.MoveNext
''         Loop
         Set xmlNodeList = xmlDoc.selectNodes("xml/PBSEPAveragePrices")
         For Each xmlnode In xmlNodeList
             LstBoxFrm.LstBox.AddItem Trim$(xmlnode.Attributes.getNamedItem("PBSCode").Text) & TB & Trim$(xmlnode.Attributes.getNamedItem("MaxQty").Text) & Trim$(xmlnode.Attributes.getNamedItem("IssueUnit").Text) & TB & Trim$(xmlnode.Attributes.getNamedItem("MaxRepeats").Text) & TB & Trim$(xmlnode.Attributes.getNamedItem("Description").Text) & TB
         Next
         Set xmlNodeList = Nothing
         LstBoxShow
         
         If LstBoxFrm.Tag <> "" Then
            ' a line selected so move to the correct item in the snapshot for use in other parts of the program
            foundDrugitem = True
            strTemp = LstBoxFrm.Tag
            deflines strTemp, lines$(), TB, 1, 0
            PBScode$ = UCase$(lines$(1))
            'snpDrug seems to be modular/global - oh dear ! we may need to store here the EPID or somesuch for future ref
            
''            snpDrug.MoveFirst
''            For x = 1 To LstBoxFrm.LstBox.ListIndex
''               snpDrug.MoveNext
''            Next
            EPItem = True
         Else
            ' cancel pressed
            escd = True
         End If
   
         Unload LstBoxFrm
      End If
   
     
   End If
            
   If blnNoEPItems Then
      ' warning message, however there should always be some EP items to choose from
      popmessagecr "#Patient Billing", "No EP average price items setup"
      escd = True
      m_FoundDrugitem = False '31Jan03 TH (PBSv4) Added
   End If
   


AttachPBScodeEnd:
   On Error GoTo 0
   Exit Sub

AttachPBScodeErr:
   popmessagecr "#Patient Billing", "Error in procedure: 'AttachPBScode'" & cr & "Error: " & Error$ & cr & "Error# " & Format$(Err)
   Resume AttachPBScodeEnd
End Sub

Private Function CreatePBSLine(ByVal xmlnode As MSXML2.IXMLDOMNode, ByVal tmwrk As Integer) As String
        '23Jan01 SF added to construct a data line that will be shown on the PBS item selection
        '31Jan03 TH (PBSv4) MERGED
        '08Mar03 TH/ATW Made private
        On Error GoTo 0
        Dim Out$, txt$
        Dim strDetail As String
        Dim strOut As String

        strDetail = ""
        'txt$ = Trim$(getfield(snpDrug!PBScode)) & " [" & Trim$(getfield(snpDrug!ManufacturersCode)) & "]" & tb & Trim$(getfield(snpDrug!brandname)) & tb & Format$(getfield(snpDrug!maxqty)) & tb & Format$(getfield(snpDrug!MaxRepeats)) & tb & Trim$(getfield(snpDrug!drugtypecode)) & tb & Trim$(getfield(snpDrug!restrictionflag)) & tb
        strDetail = Trim$(xmlnode.Attributes.getNamedItem("PBSCode").Text) & " [" & Trim$(xmlnode.Attributes.getNamedItem("ManufacturersCode").Text) & "]" & TB & Left$(Trim$(xmlnode.Attributes.getNamedItem("BrandName").Text) & Space$(40), 40) & TB & Format$(xmlnode.Attributes.getNamedItem("NSVCode").Text) & TB & Format$(xmlnode.Attributes.getNamedItem("MaxQty").Text) & TB & Format$(xmlnode.Attributes.getNamedItem("MaxRepeats").Text) & TB & Trim$(xmlnode.Attributes.getNamedItem("DrugTypeCode").Text) & TB & Trim$(xmlnode.Attributes.getNamedItem("RestrictionFlag").Text) & TB   '31Jan03 TH (PBSv4)
        If Val(xmlnode.Attributes.getNamedItem("BrandPremium").Text) > 0 Then
            strOut = Format$(xmlnode.Attributes.getNamedItem("BrandPremium").Text, "#0.00")
            'poundsandpence(out$, False)
            strDetail = strDetail & "$" & Trim$(strOut) & " [B]"
        ElseIf (Val(xmlnode.Attributes.getNamedItem("TherapeuticPremium").Text) > 0) Then
            strOut = Format$(xmlnode.Attributes.getNamedItem("TherapeuticPremium").Text, "#0.00")
            ''poundsandpence(out$, False)
            ''txt$ = txt$ & money(5) & Trim$(out$) & " [T]"
            strDetail = strDetail & "$" & Trim$(strOut) & " [T]"
        Else
            'txt$ = txt$ & money(5) & "0.00"
            strDetail = strDetail & "$" & "0.00"
        End If
        strDetail = strDetail & TB
        strOut = Format$(xmlnode.Attributes.getNamedItem("CommonWealthDispensed").Text, "#0.00")
        ''poundsandpence(out$, False)
        ''txt$ = txt$ & money(5) & Trim$(out$) & tb
        strDetail = strDetail & "$" & Trim$(strOut) & TB
        strOut = Format$(xmlnode.Attributes.getNamedItem("MaxRecordableValue").Text, "#0.00")
        ''poundsandpence(out$, False)
        ''txt$ = txt$ & money(5) & Trim$(out$) & tb
        strDetail = strDetail & "$" & Trim$(strOut) & TB

        'LstBoxFrm strDetail)
        CreatePBSLine = strDetail
        ''LstBoxFrm.LstBox.Items.Item(LstBoxFrm.LstBox.SelectedIndex). = (snpDrug!id)

        '31Jan03 TH (PBSv4) Removed block
        '' separate entry for a drug with that can have a solvent added
        'If Not tmwrk Then
        '    If getfield(snpDrug!SolventRequired) Then
        '            LstBoxFrm.LstBox.AddItem tb & Trim$(getfield(snpDrug!brandname)) & " with SOLVENT added"
        '        End If
        '    End If
        '------------------------

    End Function
Sub CastXMLToPBSProduct(ByVal xmlnode As MSXML2.IXMLDOMNode, ByRef PBSProd As PBSProduct)
'09May05 Cast record to product structure

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "CastRSToPBSProduct"

   On Error Resume Next '''GoTo ErrorHandler
   PBSProd.PBSProductID = Trim$(xmlnode.Attributes.getNamedItem("PBSProductID").Text) 'PK
   PBSProd.DrugID = Trim$(xmlnode.Attributes.getNamedItem("DrugID").Text)
   PBSProd.ATCCode = Trim$(xmlnode.Attributes.getNamedItem("ATCcode").Text)
   PBSProd.ATCType = Trim$(xmlnode.Attributes.getNamedItem("ATCtype").Text)
   PBSProd.ATCPrintOption = Trim$(xmlnode.Attributes.getNamedItem("ATCPrintOption").Text)
   PBSProd.PBScode = Trim$(xmlnode.Attributes.getNamedItem("PBSCode").Text)
   PBSProd.RestrictionFlag = Trim$(xmlnode.Attributes.getNamedItem("RestrictionFlag").Text)
   PBSProd.CautionFlag = Trim$(xmlnode.Attributes.getNamedItem("CautionFlag").Text)
   PBSProd.NoteFlag = Trim$(xmlnode.Attributes.getNamedItem("NoteFlag").Text)
   PBSProd.maxqty = Trim$(xmlnode.Attributes.getNamedItem("MaxQty").Text)
   PBSProd.MaxRepeats = Trim$(xmlnode.Attributes.getNamedItem("MaxRepeats").Text)
   PBSProd.ManufacturersCode = Trim$(xmlnode.Attributes.getNamedItem("ManufacturersCode").Text)
   PBSProd.ROP = Trim$(xmlnode.Attributes.getNamedItem("ROP").Text)
   PBSProd.brandpremium = Trim$(xmlnode.Attributes.getNamedItem("rs!BrandPremium").Text)
   PBSProd.TherapeuticPremium = Trim$(xmlnode.Attributes.getNamedItem("TherapueticPremium").Text)
   PBSProd.CommonWealthPrice = Trim$(xmlnode.Attributes.getNamedItem("CommonWealthPrice").Text)
   PBSProd.CommonWealthDispensed = Trim$(xmlnode.Attributes.getNamedItem("CommonWealthDispensed").Text)
   PBSProd.TherapeuticGroupPrice = Trim$(xmlnode.Attributes.getNamedItem("TherapeuticGroupPrice").Text)
   PBSProd.TherapeuticGroupDispensed = Trim$(xmlnode.Attributes.getNamedItem("TherapeuticGroupDispensed").Text)
   PBSProd.PriceToPharmacy = Trim$(xmlnode.Attributes.getNamedItem("PriceToPharmacy").Text)
   PBSProd.DispensedPriceMaxQty = Trim$(xmlnode.Attributes.getNamedItem("DispensedPriceMaxQty").Text)
   PBSProd.MaxRecordableValue = Trim$(xmlnode.Attributes.getNamedItem("MaxRecordableValue").Text)
   PBSProd.BioEquivelence = Trim$(xmlnode.Attributes.getNamedItem("BioEquivelence").Text)
   PBSProd.BrandName = Trim$(xmlnode.Attributes.getNamedItem("BrandName").Text)
   PBSProd.GenericName = Trim$(xmlnode.Attributes.getNamedItem("GenericName").Text)
   PBSProd.FormAndStrength = Trim$(xmlnode.Attributes.getNamedItem("FormAndStrength").Text)
   PBSProd.SolventRequired = Trim$(xmlnode.Attributes.getNamedItem("SolventRequired").Text)
   PBSProd.PBSSubsidised = Trim$(xmlnode.Attributes.getNamedItem("PBSSubsidised").Text)
   PBSProd.Description = Trim$(xmlnode.Attributes.getNamedItem("Description").Text)
   PBSProd.DrugTypeCode = Trim$(xmlnode.Attributes.getNamedItem("DrugTypeCode").Text)
   On Error GoTo 0
Cleanup:
   'On Error Resume Next
   '
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Sub

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Sub
Private Sub CostOfItem(ByVal blnPrivate As Integer, ByVal PBSProductID As Long)
'TH Written as replacement to original CostOfItem proc. This now allows private costing/PBS
'   Costing/Reg 24 Costing as options rather than displaying all costs upfront as previous.
'06May03 TH Replaced Title for multiple issue option

Dim snap As Snapshot
Dim SQL$, Item$, txt$, Out$, premium$, premiumDisplay$
Dim cost!
Dim intQty As Integer, strQty As String, blnContinue As Integer
Dim strOption As String, blnAuthority As Integer
Dim intOK As Integer
Dim objBilling As Object
Dim strOut As String



   
   On Error GoTo NewCostOfItemErr
   blnContinue = True
   If Not blnPrivate Then
      frmoptionset -1, "PBS Costing Information"
      frmoptionset 1, "Costing for Standard Quantity"
      frmoptionset 1, "Costing for Regulation 24"
      frmoptionset 1, "Costing for Private Quantity"
      frmoptionshow "1", strOption
      frmoptionset 0, ""
      Select Case Val(strOption)
      Case 0: blnContinue = False
      Case 2: blnAuthority = True
      Case 3: blnPrivate = True
      Case Else
      End Select
   End If
   If blnContinue Then
     If blnPrivate Then
         strQty = "0"
         inputwin "Patient Billing", "Enter Qty to be costed in " & Trim$(d.PrintformV), strQty, k
         If Not k.escd And Val(strQty) > 0 Then
            intQty = Val(strQty)
            blnContinue = True
         End If
      ElseIf blnAuthority Then
         strQty = "0"
         inputwin "Patient Billing", "Enter Number of Issues to be costed", strQty, k
         If Not k.escd And Val(strQty) > 0 Then
            intQty = Val(strQty)
            blnContinue = True
         End If
   
      Else
         intQty = 1
         blnContinue = True
      End If
   End If
   If blnContinue Then
      'Set objBilling = CreateObject(m_strBillingComponent)
      'strOut = objBilling.CostOfItem(g_SessionID, PBSProductID, EPItem, blnPrivate, d.convfact, intQty, gDispSite, d.tradename, d.PrintformV, d.Description, d.cost)
      'Set objBilling = Nothing
      ''99PBS TH This needs moving to billing component
''      strParams = gTransport.CreateInputParameterXML("EPItem", trnDataTypeBit, 1, 1) & _
''                  gTransport.CreateInputParameterXML("Private", trnDataTypeBit, 1, blnPrivate) & _
''                  gTransport.CreateInputParameterXML("Convfact", trnDataTypeint, 1, d.convfact) & _
''                  gTransport.CreateInputParameterXML("Qty", trnDataTypeint, 1, intQty) & _
''                  gTransport.CreateInputParameterXML("Tradename", trnDataTypeint, 1, d.tradename) & _
''                  gTransport.CreateInputParameterXML("PrintFormV", trnDataTypeint, 1, d.PrintformV) & _
''                  gTransport.CreateInputParameterXML("Description", trnDataTypeint, 1, d.Description) & _
''                  gTransport.CreateInputParameterXML("Cost", trnDataTypeint, 1, d.cost)
''      strOut = BillingInterface(g_SessionID, "GetCostofItem", strParams, PBSProductID)
      'strOut = PBSCostOfItem(g_SessionID, PBSProductID, EPItem, blnPrivate, d.convfact, intQty, gDispSite, d.tradename, d.PrintformV, d.Description, d.cost) XN 4Jun15 98073 New local stores description
      strOut = PBSCostOfItem(g_SessionID, PBSProductID, EPItem, blnPrivate, d.convfact, intQty, gDispSite, d.tradename, d.PrintformV, d.LabelDescription, d.cost)
      popmessagecr "", strOut
   End If

NewCostOfItemEnd:
   On Error Resume Next
   On Error GoTo 0
   Exit Sub

NewCostOfItemErr:
   popmessagecr "#Patient Billing", "Cannot display the cost of the item, Error: " & Error$ & " (" & Format$(Err) & ")"
   Resume NewCostOfItemEnd

End Sub
Private Sub ValidateCardNumber(ByVal toCheck$, cardType$, ByRef valid As Integer)
Dim strValidationXML As String
Dim blnValid As Boolean
Dim strTxt As String
Dim checkDigit As Integer
Dim total As Integer
Dim intFor As Integer
Dim strAns As String


   Select Case UCase$(Trim$(cardType$))
      Case "A":
         'strValidationXML = BillingInterface(SessionID, "ValidateAuthorityNumber", "", PBSProductID)
            If Len(toCheck$) > 8 Then
               strTxt = "Invalid Authority Number" & cr & "Length cannot be greater than eight digits"
            ElseIf Not IsDigits(toCheck$) Then
               strTxt = "Invalid Authority Number" & cr & "The whole number must be numeric"
            Else
               toCheck$ = Format$(toCheck$, "00000000")
               checkDigit = Val(Right$(toCheck$, 1))
               total = 0
               For intFor = 1 To 7
                  total = total + Val(Mid$(toCheck$, intFor, 1))
               Next
               If total Mod 9 <> checkDigit Then strTxt = "Invalid Authority Number" & cr & "Failed the check digit"
            End If

   
      Case "P":
   End Select
   If Trim$(strTxt) <> "" Then
      ' invalid number
      strAns = "N"
      'If noMessage Then       '31Jan03 TH (PBSv4)
      '   valid = False     '    "
      'Else                 '    "
      '   ans$ = "N"
         askwin "?Patient Billing", "'" & toCheck$ & "' " & strTxt & cr & cr & "Do you want to continue with this number?", strAns, k
         If strAns = "Y" And (Not k.escd) Then
            valid = True
         Else
            valid = False
         End If
      'End If               '    "
   Else
   ' valid number
      valid = True
   End If

End Sub
Sub ExceptionalPricing(blnWrite As Integer, sglValue As Single)
'31Jan03 TH (PBSv4) Written, Read/Write to modular level exceptional pricing flag for PBS
'31Jan03 TH (PBSv4) MERGED

   If blnWrite Then
         m_sglExceptionalPrice = sglValue
      Else
         sglValue = m_sglExceptionalPrice
      End If

End Sub
Private Function NumberOfRepeats() As Integer
'16May00 SF now uses l.prescriptionID for both PBS and Pharmac as the rx#
'14Jul00 SF added Repeat Dispensing mods
'31Jan03 TH (PBSv4) MERGED


'Dim objBilling As Object
'Dim strXML As String
'Dim xmldoc As MSXML2.DOMDocument


   On Error GoTo NumberOfRepeatsErr

''   '16Nov99 SF added case statement to allow lookup on prescriptionid for PBS
''   Select Case 2:                      '31Jan03 TH (PBSv4) Differentiate now for PBS where repeat interval is also required
''         sql$ = "SELECT drugrepeats.numberofrepeats, drugrepeats.repeatinterval FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
''   End Select
''
''   Set snap = Patdb.CreateSnapshot(sql$)
   
''   Set objBilling = CreateObject(m_strBillingComponent)
''   strXML = objBilling.PBSNumberofRepeatsandInterval(g_SessionID, pid.recno, L.prescriptionid)
''   Set objBilling = Nothing
''   If InStr(LCase(strXML), "pbsdrugrepeat") > 0 Then 'And (Not m_blnPBSNewScript
''   'If Not snap.EOF And (Not m_blnPBSNewScript) Then  '31Jan03 TH (PBSv4) Added new clause
''      If xmldoc.loadXML(strXML) Then
''      'Get the nodes abd git
''''         NumberOfRepeats% = CInt(GetField(snap!NumberOfRepeats)) '08Mar03 TH/ATW Replaced trim with cint
''''         m_intRepeatInterval = GetField(snap!repeatInterval)  '31Jan03 TH (PBSv4) Added
''      Else
''         NumberOfRepeats% = -1
''      End If
''   Else
''      NumberOfRepeats% = -1
''   End If
   NumberOfRepeats = m_PBSDrugRepeat.NumberOfRepeats

NumberOfRepeatsExit:
   
   On Error GoTo 0
   Exit Function

NumberOfRepeatsErr:
   FatalErr% = True
   NumberOfRepeats% = 0
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: NumberOfRepeats) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & Error$ & cr & "Error number: " & Err             '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: NumberOfRepeats) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & Error$ & cr & "Error number: " & Err   '16May00 SF
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: NumberOfRepeats" & cr & "Error: " & Error$ & cr & "Error number: " & Err
   Resume NumberOfRepeatsExit

End Function
Private Function ItemForBilling%()
'16Nov99 SF checks whether the item issued should use the patient billing module
'18Nov99 SF puts different hospital text on heap for printing depending on whether PBS or public dispensing
'14Jul00 SF added Repeat Dispensing mods
'31Jan03 TH (PBS v4) MERGED
'31Jan03 TH (PBS v4)  Changes to allow DispensOverCaseNum to be bypassed to make PBS more generic (not specific to Hobart)
'08Mar03 TH/ATW Privatised

Dim range$, lines$()
Dim OK%, X%, numoflines%


   OK = False

   
         ' for PBS only dispense if case# in specified range
         '31Jan03 TH (PBS v4) Big switch off if required.
         If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "AskPBSDispensQuestion", 0)) Then  '31Jan03 TH (PBS v4)
               OK = m_blnPBSDispenseOn                                                              '    "
            Else                                                                                    '    "
               ReDim lines$(100)
               range$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "DispensOverCaseNum", 0)
               deflines range$, lines$(), ",", 1, numoflines
               'If (numoflines = 0) Or (numoflines Mod 2 > 0) Then                        '31Jan03 TH (PBS v4)  Changes to allow DispensOverCaseNum to be bypassed
               If ((numoflines = 0) Or (numoflines Mod 2 > 0)) And range$ <> "" Then      '    "                to make PBS more generic (not specific to Hobart)
                     popmessagecr "!Patient Billing", "Must setup case number range correctly"
                  Else
                     If range$ <> "" Then                                               '31Jan03 TH (PBS v4)
                           For X = 1 To numoflines Step 2
                              If Val(pid.caseno) >= Val(lines(X)) And Val(pid.caseno) <= Val(lines$(X + 1)) Then
                                    OK = True
                                    Exit For
                                 End If
                           Next
                        Else                                                            '31Jan03 TH (PBS v4)
                           OK = True                                                    '    "
                        End If                                                          '    "
                     '18Nov99 SF now sets up hospital text to print depending on public or PBS dispensing
                     If OK Then                                                                                                                 '31Jan03 TH (PBS v4)
                           If InStr(TxtD$(dispdata$ & BillIniFile$, "PatientBilling", "O", "PatientTypes", 0), pid.Status) = 0 Then OK = False  '   "
                        End If                                                                                                                  '   "
                  End If                                                                               '31Jan03 TH (PBS v4)
            End If   '31Jan03 TH (PBS v4) Moved from below to ensure heap elements get on the heap
            If OK Then
                  ' PBS
                        Heap 10, gPRNheapID, "pbHospTxt", Trim$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "LblPBStext", 0)), 0
               Else
                  ' Public
                        Heap 10, gPRNheapID, "pbHospTxt", Trim$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "LblPublicText", 0)), 0
               End If
            '18Nov99 SF -----

            'End If  '31Jan03 TH (PBS v4) Moved above


   m_blnPBSDispenseOn = OK '31Jan03 TH (PBS v4) Added
   ItemForBilling% = OK

End Function

Sub GetCurrentPrescriberDetails()

'TH Sep06 Eventually this will read the preselected prescriber details from the state table ?

   'To DB
   popmessagecr "STILL TO DO", "Read Prescriber Details here from State"
   'If success Then
      On Error GoTo 0
''      gPrescriberID$ = "1"
''      m_Prescriber.Code = "76319831"
''      m_Prescriber.inuse = "Y"
''      m_Prescriber.name = "Dr Dummy"
''      m_Prescriber.Address1 = "10 Street"
''      m_Prescriber.Address2 = "DummyTown"
''      m_Prescriber.Address3 = "DummyState"
''      m_Prescriber.postCode = "Post 123"
''      m_Prescriber.telephonenumber = "999 99999"
''      m_Prescriber.specialist = "Surgery"
''      m_Prescriber.secondaryCode = "2222222"
''      m_Prescriber.registrationNumber = "876543"
''      ''''m_Prescriber.datecreated = CDate("2006-09-11 00:00:00")
''      m_Prescriber.prescribertype = "GE"
''      m_Prescriber.freetext = "This is just a dummy record for now"
   'End If
                 


End Sub
Sub GetPrescriberDetails(fromPMR%, RxCode$, success%, ByRef Prescriber As PrescriberStruct)

'TH Sep06 Eventually this will read the preselected prescriber details from the state table ?

   'To DB
   popmessagecr "STILL TO DO", "Read Prescriber Details here from RxCode"
   'If success Then
      gPrescriberID$ = "1"
      Prescriber.Code = "76319831"
      Prescriber.inuse = "Y"
      Prescriber.name = "Dr Dummy"
      Prescriber.Address1 = "10 Street"
      Prescriber.Address2 = "DummyTown"
      Prescriber.Address3 = "DummyState"
      Prescriber.postCode = "Post 123"
      Prescriber.telephonenumber = "999 99999"
      Prescriber.specialist = "Surgery"
      Prescriber.secondaryCode = "2222222"
      Prescriber.registrationNumber = "876543"
      Prescriber.datecreated = "2006-09-11 00:00:00"
      Prescriber.prescribertype = "GE"
      Prescriber.freetext = "This is just a dummy record for now"
   'End If
                 


End Sub
Sub GetfamilyAmounts(ByRef FamilyThresholdAmount As Single, ByRef FamilyScripts As Single, ByVal Familygroupnumber As Single)
'31Jan03 TH (PBSv4) written to quickly calculate total family threshold amount (NB can only be called when Patid is open)
'31Jan03 TH (PBSv4) MERGED
'25Mar03 TH (PBSv4) Added Error Trapping

Dim myError$
Dim myErr As Integer

On Error GoTo GetfamilyAmountsErr

''   famsql$ = "SELECT sum(patbilling.ThresholdAmount) as [FamilyThresholdAmount], sum(patbilling.scripts) as [FamilyScripts] FROM PatBilling WHERE PatBilling.FamilyGroupNumber = " & Familygroupnumber & ";"
''   Set famsnap = PIDdb.CreateSnapshot(famsql$)
''   FamilyThresholdAmount = (famsnap.Fields("FamilyThresholdAmount"))
''   FamilyScripts = (famsnap.Fields("FamilyScripts"))
''   famsnap.Close
''   Set famsnap = Nothing
   popmessagecr "STILL TO DO", "Read Family Amounts Here"
   FamilyThresholdAmount = 0
   FamilyScripts = 0
   Familygroupnumber = 0
   


GetfamilyAmountsEnd:
   On Error Resume Next
''   famsnap.Close: Set famsnap = Nothing
   On Error GoTo 0
   Exit Sub
GetfamilyAmountsErr:
   myError$ = Error$
   myErr = Err
   popmessagecr ".Patient Billing", "Error in procedure: GetfamilyAmounts" & cr & cr & "Error: " & myError$ & cr & "Error number: " & Format$(myErr)
''   Resume GetfamilyAmountsEnd

End Sub
Sub PBSGetFeesDetails()

Dim objBilling As Object
Dim strXML As String
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMNode

   'TH 99PBS Set objBilling = CreateObject(m_strBillingComponentURL)
   'strXML = objBilling.PBSPaymentFees(g_SessionID)
   'Set objBilling = Nothing
   strXML = BillingInterface(g_SessionID, "GetPBSPaymentFees", "", 0)
   If InStr(LCase(strXML), "pbspaymentfees") > 0 Then 'And (Not m_blnPBSNewScript
      Set xmlDoc = New MSXML2.DOMDocument
      If xmlDoc.loadXML(strXML) Then
         'm_PatFees.AdditionalFeeEP =
         Set xmlnode = xmlDoc.selectSingleNode("xml/PBSPaymentFees")
         m_PatFees.PBSmarkupLow = Val(xmlnode.Attributes.getNamedItem("PBSmarkupLow").Text)
         m_PatFees.PBSmarkupMid = Val(xmlnode.Attributes.getNamedItem("PBSmarkupMid").Text)
         m_PatFees.PBSmarkupHigh = Val(xmlnode.Attributes.getNamedItem("PBSmarkupHigh").Text)
         m_PatFees.PBSlowMarkupLevel = Val(xmlnode.Attributes.getNamedItem("PBSlowMarkupLevel").Text)
         m_PatFees.PBShighMarkupLevel = Val(xmlnode.Attributes.getNamedItem("PBShighMarkupLevel").Text)
         m_PatFees.PrivateMarkup = Val(xmlnode.Attributes.getNamedItem("PrivateMarkup").Text)
         m_PatFees.PrivateDispensingFee = Val(xmlnode.Attributes.getNamedItem("PrivateDispensingFee").Text)
         m_PatFees.CompositeFeeRP = Val(xmlnode.Attributes.getNamedItem("CompositeFeeRP").Text)
         m_PatFees.CompositeFeeEP = Val(xmlnode.Attributes.getNamedItem("CompositeFeeEP").Text)
         m_PatFees.AdditionalFeeRP = Val(xmlnode.Attributes.getNamedItem("AdditionalFeeRP").Text)
         m_PatFees.AdditionalFeeEP = Val(xmlnode.Attributes.getNamedItem("AdditionalFeeEP").Text)
         m_PatFees.AllowableExtraFee = Val(xmlnode.Attributes.getNamedItem("AllowableExtraFee").Text)
         m_PatFees.GeneralPatient = Val(xmlnode.Attributes.getNamedItem("GeneralPatient").Text)
         m_PatFees.ConcessionPatient = Val(xmlnode.Attributes.getNamedItem("ConcessionPatient").Text)
         m_PatFees.SafetyNetConcession = Val(xmlnode.Attributes.getNamedItem("SafetyNetConcession").Text)
         m_PatFees.SafetyNetEntitlement = Val(xmlnode.Attributes.getNamedItem("SafetyNetEntitlement").Text)
         m_PatFees.GenPatSafety = Val(xmlnode.Attributes.getNamedItem("GenPatSafety").Text)
         m_PatFees.ConPatSafety = Val(xmlnode.Attributes.getNamedItem("ConPatSafety").Text)
         m_PatFees.dangerousdrugfee = Val(xmlnode.Attributes.getNamedItem("DangerousDrugFee").Text)
         m_PatFees.containerPrice = Val(xmlnode.Attributes.getNamedItem("ContainerPrice").Text)
         m_PatFees.WaterFee = Val(xmlnode.Attributes.getNamedItem("WaterFee").Text)
         m_PatFees.GenFamSafety = Val(xmlnode.Attributes.getNamedItem("GenFamSafety").Text)
         m_PatFees.ConFamSafety = Val(xmlnode.Attributes.getNamedItem("ConFamSafety").Text)
         m_PatFees.InjectableContainerPrice = Val(xmlnode.Attributes.getNamedItem("InjectableContainerPrice").Text)
         m_PatFees.HSDmarkupLow = Val(xmlnode.Attributes.getNamedItem("HSDmarkupLow").Text)
         m_PatFees.HSDmarkupMid = Val(xmlnode.Attributes.getNamedItem("HSDmarkupMid").Text)
         m_PatFees.HSDmarkupHigh = Val(xmlnode.Attributes.getNamedItem("HSDmarkupHigh").Text)
         m_PatFees.HSDlowMarkupLevel = Val(xmlnode.Attributes.getNamedItem("HSDlowMarkupLevel").Text)
         m_PatFees.HSDhighMarkupLevel = Val(xmlnode.Attributes.getNamedItem("HSDhighMarkupLevel").Text)
         'blnFeesLoadedOK = tre
         Set xmlnode = Nothing
      End If
      Set xmlDoc = Nothing
   End If


End Sub

Private Function NumberOfOwes!(origDispens!)
'16May00 SF now uses l.prescriptionID for both PBS and Pharmac as the rx#
'14Jul00 SF added Repeat Dispensing mods
'08Mar03 TH/ATW Privatised

''Dim sql$, opened%

   ''opened% = False
   On Error GoTo NumberOfOwesErr
   
   ''popmessagecr "STILL TO DO !!", "Number of owes"
   

''   '16Nov99 SF added case statement to allow lookup on prescriptionid for PBS
''   Select Case billingtype
''      '16May00 SF now uses l.prescriptionID for both PBS and Pharmac
''      'Case 1:
''      '   sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
''      'Case 2:
''      '16May00 SF -----
''      'Case 1, 2:       '14Jul00 SF replaced
''      Case 1, 2, 3:     '14Jul00 SF added Repeat Dispensing
''         sql$ = "SELECT * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
''   End Select
''
''   Set snap = Patdb.CreateSnapshot(sql$)
''   opened% = True   '
''
''   If Not snap.EOF Then
''         NumberOfOwes! = GetField(snap!QtyOwing)
''         origDispens! = GetField(snap!DispensQty)
''      Else
''         NumberOfOwes! = -1
''         origDispens! = 0
''      End If
      
      If m_PBSDrugRepeat.PBSDrugRepeatID > 0 Then
         NumberOfOwes! = m_PBSDrugRepeat.QtyOwing
         origDispens! = m_PBSDrugRepeat.DispensQty
      Else
         NumberOfOwes! = -1
         origDispens! = 0
      End If
   

NumberOfOwesExit:
   
   On Error GoTo 0
   Exit Function

NumberOfOwesErr:
   FatalErr% = True
   'WriteLog dispdata$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: NumberOfOwes) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & Error$ & cr & "Error number: " & Err             '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: NumberOfOwes) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & Error$ & cr & "Error number: " & Err   '16May00 SF
   NumberOfOwes! = -1
   origDispens! = 0
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: NumberOfOwes" & cr & "Error: " & Error$ & cr & "Error number: " & Err
   Resume NumberOfOwesExit

End Function

Private Sub PatientBilling(escd%)
'10Oct99 mods to allow the drug to be dispened as a private item if not found in the Pharmac data
'        now allows the default expiry date to be overwritten with the one stored in the Pharmac data (entered by the user through stkmaint)
'24Nov99 SF now records safety net total with debug info if appropriate
'02Dec99 SF removed goto when escaped from unoriginal window to allow escd code to fire and now only calls PBSItemBillCalcs: if not previously escaped
'16May00 SF if not pharmac subsidy for an item the the item will now be a private dispensing
'16May00 SF for pharmac if a repeat then disable item expiry date, special authority fields
'16May00 SF now uses l.prescriptionid instead of labf& as the rx#
'11Jul00 SF added Repeat Dispensing mods
'16Nov00 SF various mods for PBS, including printing and owing report an receipts
'16Nov00 SF Pharmac variable qty repeat mods
'31Jan03 TH (PBSv4) Record No of scripts issued to patient (for threshold conversions)
'31Jan03 TH (PBSv4) MERGED
'08Mar03 TH/ATW Privatised
'16Mar03 TH (PBSv4) Added to allow for saved but not issued records to be labled as possible PBS items not Private necessarily
'18Mar03 TH (PBSv4) Added switch to handle need for issue or patient panel updates
'23Feb03 TH (PBSv4) Added mods to handle Exceptional items
'24Jun03 TH Added setting to allow for the PBS Details quescroll screen to pop modally automatically during the issue process
'24Jun03 TH Renamed ArseClown Setting above
'20Oct03 TH Reinstated old way of working for Non-PBS. OverSight when doing PBS v4
'20Oct03 TH Reinstated correct error handling (merge error)

Dim startdt As DateAndTime
Dim temp As DateAndTime
Dim startdate&, drugName$, SQL$, view$, lines$(), dat$ '08Mar03 TH/ATW Removed repeats%,
Dim NumOfEntries%, i%, valid%    '08Mar03 TH/ATW Removed , HBLsuccess%
'Dim snap As Snapshot                         '16Nov99 SF added  '08Mar03 TH/ATW Removed
Dim myError$, myErr%, prescriptionOwed%      '16Nov99 SF added
'14Jul00 SF added
Dim DT1 As DateAndTime
Dim qtyOwed!, repeatsAllowed%, success%, txt$, repeatByDate$
'14Jul00 SF -----
'Dim variableqtys$    '16Nov00 SF added to hold the variable qtys of pharmac repeats   '08Mar03 TH/ATW Removed
Dim blnDangerousDrug As Integer, strDangerousDrugCode As String                                            '31Jan03 TH (PBSv4) Added
Dim blnPBSEditFromDispens As Integer, blnPBSIssueChecksDone As Integer, blnContinue As Integer, blnQuesTag '    "
Dim intRepeats As Integer, strAmountToThreshold As String                                                  '    "
Dim blnPBSPrivate As Integer                                                                               '    "
Dim intNotIssuedPossiblePBS As Integer    '16Mar03 TH (PBSv4) Added
Dim intPatientorIssue As Integer   '18Mar03 TH (PBSv4)

   ''On Error GoTo PatientBillingErr
   'On Error GoTo 0     '20Oct03 TH Removed (merge error)
   
   'If escd% = 3 Then                   '31Jan03 TH (PBSv4)
   If escd% = 3 Or escd% = 6 Then         '18Mar03 TH (PBSv4) Replaced
      blnPBSEditFromDispens = True  '    "
      If escd% = 3 Then                '18Mar03 TH (PBSv4)
         intPatientorIssue = 1         '    "
      Else                             '    "
         intPatientorIssue = 2         '    "
      End If                           '    "
      escd% = 0                     '    "
   End If                           '    "
   If escd% = 4 Then                   '    "
      blnPBSIssueChecksDone = True  '    "
      escd% = 0                     '    "
   End If                           '    "
   If escd% = 5 Then                   '    "
      blnPBSPrivate = True          '    "
      blnPBSEditFromDispens = True  '    "
      escd% = 0                     '    "
   End If                           '    "
   
   drugName$ = Trim$(d.LabelDescription)  ' drugName$ = Trim$(d.Description) XN 4Jun15 98073 New local stores description
   plingparse drugName$, "!"

   
   If Not blnPBSIssueChecksDone Then '31Jan03 TH (PBSv4)
      ' set up ques scroll with billing information
      Unload Ques
      If blnPBSPrivate Then                                                                        '31Jan03 TH (PBSv4)
         ConstructView dispdata$ & BillIniFile$, "Views", "Data", 6, "", 0, "", NumOfEntries%      '    "
      Else                                                                                         '    "
         ConstructView dispdata$ & BillIniFile$, "Views", "Data", 2, "", 0, "", NumOfEntries%
      End If                                                                                       '    "
      QuesMakeCtrl 0, 1000    ' enable the print button
      'setQuesdefaults         ' populate ques scroll with default values     '31Jan03 TH (PBSv4) Added to retain entries
      '16Mar03 TH (PBSv4) Added Block
      intNotIssuedPossiblePBS = 0
      'If l.Nodissued = 0 Then                       '17Mar03 TH (PBSv4) Added
      If L.Nodissued = 0 And Not foundDrugitem Then  '    "
      'Saved or cancelled line - need to set default here if nsvcode is in PBS table then set to P as default in itemstatus
         intNotIssuedPossiblePBS = billpatient(33, "")
      End If
      '------------------------------------
      'If Not m_blnKeepBillitems Then setQuesdefaults 0                         '    "  '09Mar03 TH (PBSv4) Added Param
      If Not m_blnKeepBillitems Then SetPBSIssueDefaults intNotIssuedPossiblePBS    '16Mar03 TH (PBSv4) Added to allow for saved but not issued
                                                                                'records to be labled as possible PBS items not Private necessarily
      If FatalErr% Then GoTo PatientBillingExit
      For i% = 1 To NumOfEntries%
         QuesSetText i, RTrim$(Billitems$(Val(Ques.lblDesc(i).Tag)))
      Next
      
      ' find the position in the view holding the number of repeats
      If blnPBSPrivate Then                                                '31Jan03 TH (PBSv4)
         view$ = TxtD(dispdata$ & BillIniFile$, "Views", "", "6", 0)       '   "
      Else                                                                 '   "
         view$ = TxtD(dispdata$ & BillIniFile$, "Views", "", "2", 0)
      End If                                                               '   "
      ReDim lines$(60)
      deflines view$, lines$(), ",", 0, NumOfEntries%
      For i% = 0 To NumOfEntries%
         If Abs(Val(lines$(i%))) = 11 Then
            If Trim$(SpecialAuthorityNum$) <> "" Then Ques.lblInfo(i) = "Authority# " & Trim$(SpecialAuthorityNum$)
         End If
         If Abs(Val(lines$(i%))) = 59 Then
            If Trim$(OriginalDate$) <> "" Then Ques.lblInfo(i) = "Unoriginal (" & Trim$(OriginalApprovalNumber$) & ")"
         End If
         If Abs(Val(lines$(i%))) = 60 Then
            '16Nov00 SF now uses the generic prescriber details
            'sql$ = "SELECT * FROM doctorinformation WHERE doctorinformation.prescribercode = '" & gPrescriberID$ & "';"
            'Set snap = PatDB.CreateSnapshot(sql$)
            'If Not snap.EOF Then
            '      Ques.lblInfo(i) = "Prescriber# " & Trim$(getfield(snap!prescriberid))
            '   Else
            '      '!!** should never happen
            '   End If
            'snap.Close : Set snap = Nothing
            valid = billpatient(18, dat$)                      ' get orinial prescriber code
            If dat$ = "" Then dat$ = Trim$(gPrescriberID)      ' if not then use the current one
            Ques.lblInfo(i) = "Prescriber: " & dat$
            '16Nov00 SF -----
         End If
      Next
   End If  '31Jan03 TH (PBSv4) Added
   ' if number of repeats already been set then do not allow certain fields to be changed
   'ItemTypeStatus False
   prescriptionOwed = False
   '31Jan03 TH (PBSv4) Removed block
   'If PBSitemStatus$ = "O" Then
   '      '16Nov00 SF modified the following code to make the user confirm that the prescription has been received
   '      'askwin "?Patient Billing", "The previous issue was dispensed in an emergency" & cr & "The prescription must have been received before any" & cr & "more dispensing can take place." & cr & cr & "Has the prescription been received?", ans$, k     '16Nov00 SF replaced
   '      popmessagecr "#Patient Billing", "The previous issue was dispensed in an emergency." & cr & "The prescription must have been received before any" & cr & "more dispensings can take place." & cr & cr & "Select 'Edit HIC Transaction' to receive this prescription."
   '      'If ans$ = "N" Or (k.escd) Then
   '            escd = True
   '            Unload Ques
   '            Screen.MousePointer = STDCURSOR
   '            GoTo PatientBillingExit
   '      '   Else
   '      '      prescriptionOwed = True
   '      '      screen.MousePointer = STDCURSOR
   '      '      popmessagecr "#Patient Billing", "Please validate the card details"
   '      '   End If
   '      '16Nov00 SF -----
   '  End If

   If FatalErr% Then GoTo PatientBillingExit
   
   ' find the position in the view holding the number of repeats
   If Not blnPBSIssueChecksDone Then
      If blnPBSPrivate Then                                                            '31Jan03 TH (PBSv4)
         Ques.Caption = "Non PBS billing for: "                                        '   "
         view$ = TxtD(dispdata$ & BillIniFile$, "Views", "", "6", 0)                   '   "
      Else                                                                             '   "
         Ques.Caption = "PBS billing for: "
         view$ = TxtD(dispdata$ & BillIniFile$, "Views", "", "2", 0)
      End If                                                                           '   "
   ReDim lines$(60)
   deflines view$, lines$(), ",", 0, NumOfEntries%
   For i% = 0 To NumOfEntries%
      ' if a repeat then do not allow the user to change the repeat qty
      '01Jun07 TH If L.batchnumber > 0 And Val(lines$(i%)) = 11 Then Ques.txtQ(i%).Enabled = False
      If m_PBSDrugRepeat.NumberOfIssues > 0 And Val(lines$(i%)) = 11 Then Ques.txtQ(i%).Enabled = False
      '16Nov00 SF added if a repeat on a normal dispensing then don't allow action to be changed
      'If (PBSitemType$ = "P") And (PBSitemStatus$ = "N") And (l.batchnumber > 0) And (Val(lines$(i)) = 53) Then Ques.txtQ(i%).Enabled = False
      If Val(lines$(i)) = 53 Then
      '01Jun07 TH If (PBSItemType$ = "P") And (PBSItemStatus$ = "N") And (L.batchnumber > 0) And (Val(lines$(i)) = 53) Then  '31Jan03 TH (PBSv4)
      If (PBSItemType$ = "P") And (PBSItemStatus$ = "N") And (m_PBSDrugRepeat.NumberOfIssues > 0) And (Val(lines$(i)) = 53) Then  '31Jan03 TH (PBSv4)
         Ques.txtQ(i%).Enabled = False
      Else                                                                                                       '    "
         Ques.txtQ(i%).Enabled = True                                                                            '    "
      End If                                                                                                     '    "
      End If
      '16Nov00 SF -----
      ' if prescription owing then only allow user to modify the card details
      If PBSItemStatus$ = "O" Then
            Select Case Val(lines$(i%))
               Case 56, 57, 58, 14, 15: Ques.txtQ(i%).Enabled = False
               Case 53:                            '31Jan03 TH (PBSv4)  Moved from above and added fencepost
               If L.batchnumber > 0 Then           '    "
                  Ques.txtQ(i%).Enabled = False    '    "
               End If                              '    "
            End Select
         End If
      ' if a private prescription then card details/safety net etc. irrelevant
      '01Jun07 TH If PBSItemType$ = "N" And L.batchnumber > 0 Then
      If PBSItemType$ = "N" And m_PBSDrugRepeat.NumberOfIssues > 0 Then
            Ques.Caption = "Private billing for: "
            Select Case Val(lines$(i%))
               Case 51, 52, 53, 56, 57, 58: Ques.txtQ(i%).Enabled = False
            End Select
         End If
      'if not dangerous drug then disable repeat interval field
      '31Jan03 TH (PBSv4)  Added
      If Val(lines$(i%)) = 77 Then
            If Not EPItem Then
                  strDangerousDrugCode = Trim$(UCase$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "DangerousDrugCode", 0)))
                  If Trim$(strDangerousDrugCode) <> "" Then
                        If InStr(strDangerousDrugCode, ".") > 0 Then
                              If Trim$(UCase$(Left$(d.bnf, 8))) = strDangerousDrugCode Then blnDangerousDrug = True
                           Else
                              If Trim$(UCase$(d.therapcode)) = strDangerousDrugCode Then blnDangerousDrug = True
                           End If
                     End If
               End If
            If Not blnDangerousDrug Then Ques.txtQ(i%).Enabled = False
         End If
      '31Jan03 TH (PBSv4)  ------------------

   Next
            
   If UCase$(Billitems$(53)) = "U" Then
      QuesSetEnabled 88, True
      QuesSetEnabled 89, True
      QuesSetEnabled 90, True
      QuesSetEnabled 91, True
   Else
      QuesSetEnabled 88, False
      QuesSetEnabled 89, False
      QuesSetEnabled 90, False
      QuesSetEnabled 91, False
   End If
   If UCase$(Billitems$(53)) = "X" Then
      QuesSetEnabled 93, True
      QuesSetEnabled 94, True
   Else
      QuesSetEnabled 93, False
      QuesSetEnabled 94, False
   End If
   
   If Trim$(d.tradename) <> "" Then                                                                                                                                    '31Jan03 TH (PBSv4)  Added Brand where appropriate
         Ques.Caption = Ques.Caption & Format$(Qty!) & " " & Trim$(d.PrintformV) & " " & drugName$ & " [" & Trim$(d.tradename) & "] (ROP " & Trim$(d.convfact) & ")"   '   "
      Else                                                                                                                                                             '   "
         Ques.Caption = Ques.Caption & Format$(Qty!) & " " & Trim$(d.PrintformV) & " " & drugName$ & " (ROP " & Trim$(d.convfact) & ")"
      End If                                                                                                                                                           '   "
   End If
   '14Jul00 SF added Repeat Dispensing
   Do
      ' display information to the user
        
      If Not blnPBSIssueChecksDone Then
         QuesCallbackMode = 12
         QuesShow NumOfEntries%
         QuesCallbackMode = 0
      End If
         '14Jul00 SF added for Repeat Dispensing
         
      If blnPBSIssueChecksDone Then     '31Jan03 TH (PBSv4)  Added
         blnQuesTag = True           '   "
      ElseIf Ques.Tag = "-1" Then    '   "
         blnQuesTag = True           '   "
      End If                         '   "
         'If Ques.Tag = "-1" Then     '31Jan03 TH (PBSv4)  Replaced
      If blnQuesTag Then
         ' ok clicked
         If blnPBSIssueChecksDone Then
            blnContinue = True
         Else
            blnContinue = AllFieldsCorrect(intPatientorIssue)
         End If                               '    "
         If PBSItemStatus$ = "U" And m_PBSDrugRepeat.NumberOfIssues = 0 Then
            m_PBSDrugRepeat.OriginalApprovalNumber = Billitems$(88)
            m_PBSDrugRepeat.OriginalScriptNumber = Billitems$(90)
            m_PBSDrugRepeat.NumberOfRepeats = Val(Billitems$(91))
            m_PBSDrugRepeat.OriginalLastIssuedDate = Billitems$(89)
            m_PBSDrugRepeat.OriginalTimesIssued = Val(Billitems$(91))
            PBSDrugRepeatWrite
         End If
         If blnContinue Then
            If FatalErr% Then GoTo PatientBillingExit
               
            If blnPBSEditFromDispens Then      '31Jan03 TH (PBSv4)  Added
               Unload Ques
               Exit Sub                     '    "
            End If                          '    "
            escd = False
            If Not escd Then PBSItemBillCalcs prescriptionOwed, escd  '02Dec99 SF only fire if not escd above
         
   
            If Not escd Then
               If PBSItemStatus$ = "D" Then
                  ' for deferred items fool program into thinking the user escaped so item not issued
                  escd = True
                  LogDeferredTransaction            '31Jan03 TH (PBSv4)  Added
               Else
                  If PBSItemStatus$ = "O" Then
                     PrintOwingPage
                  End If
                  
                  If Billitems$(63) = "Y" Then
                     PrintReceipts      '16Nov00 SF added to print a receipt
                  End If
                  ' update safety net threshold amount paid
                  If Billitems$(53) = "P" Or Billitems$(53) = "R" Then        '31Jan03 TH (PBSv4)
                     '24Nov99 SF now records safety net total with debug info if appropriate
                     'dat$ = Format$(Val(BillItems$(54)) + safetyNetValue!)
                     If debugSafetyNet$ = "" Then
                        dat$ = Format$(Val(Billitems$(54)) + SafetyNetValue!)
                        strAmountToThreshold = Format$(SafetyNetValue!)    '31Jan03 TH (PBSv4)  Added
                     Else
                        dat$ = Format$(Val(Billitems$(54)) + Val(debugSafetyNet$))
                        strAmountToThreshold = debugSafetyNet$             '31Jan03 TH (PBSv4)  Added
                     End If
                     poundsandpence dat$, False
                     Billitems$(54) = Trim$(dat$)
                     '16Nov00 SF update threshold amount in case press "Edit PBS details" button
                     popmessagecr "TO DO", "Update script info"
   ''''                                          PatInfo.Edit
   ''''                                          If Billitems$(53) = "R" Then
   ''''                                             intRepeats = NumberOfRepeats()
   ''''                                             PatInfo!ThresholdAmount = Val(Billitems$(54)) + (intRepeats * Val(strAmountToThreshold))
   ''''                                             PatInfo!Scripts = (PatInfo!Scripts) + 1 + intRepeats
   ''''                                          Else
   ''''                                          PatInfo!ThresholdAmount = Val(Billitems$(54))
   ''''                                             PatInfo!Scripts = (PatInfo!Scripts) + 1    '31Jan03 TH (PBSv4)  Record No of scripts
   ''''                                          End If
   ''''                                          PatInfo.Update
                     If Billitems$(53) = "R" Then
                        intRepeats = NumberOfRepeats()
                        m_PBSPatient.ThresholdAmount = Val(Billitems$(54)) + (intRepeats * Val(strAmountToThreshold))
                        m_PBSPatient.Scripts = (m_PBSPatient.Scripts) + 1 + intRepeats
                     Else
                        m_PBSPatient.ThresholdAmount = Val(Billitems$(54))
                        m_PBSPatient.Scripts = (m_PBSPatient.Scripts) + 1    'Record No of scripts
                     End If
                  End If
                  If Not prescriptionOwed Then
                     LogTransaction        'Only writes HIC transaction if a written prescription presented
                     ''popmessagecr "TO DO", "LogTransaction"
                  Else
                     ItemTypeStatus True, "", "", "", ""
                     'Write the HIC transaction and inform the user
                     LogTransaction
                     popmessagecr "#Patient Billing", "The owing transaction has been written to HIC"
                     escd = True
                  End If
                  If PBSItemStatus$ = "R" Then
                        'sql$ = "UPDATE drugrepeats SET drugrepeats.numberofrepeats = 0, drugrepeats.dispensqty = " & Format$(Qty!) & " WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
   ''                                          sql$ = "UPDATE drugrepeats SET drugrepeats.numberofrepeats = 0, drugrepeats.dispensqty = " & Format$(Qty!) & " WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
   ''                                          WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
   ''                                          Patdb.Execute (sql$): DoSaferEvents 1
               
                     'popmessagecr "TO DO", "Update Repeats"
                     m_PBSDrugRepeat.NumberOfRepeats = 0
                     m_PBSDrugRepeat.DispensQty = Qty!
                     'The Write will be handled below
                  End If
               End If
            End If
            If Not escd Then ItemTypeStatus True, "", "", "", ""
         Else
            If FatalErr% Then GoTo PatientBillingExit
            Ques.Tag = "0"    ' ensure stay in loop until all fields entered
            blnQuesTag = False
         End If
      Else
         ' cancel clicked
         escd% = True
         Exit Do
      End If
   
   Loop Until blnQuesTag = True
   
       
   If blnPBSIssueChecksDone Or (TrueFalse(TxtD$(dispdata & "\" & "patmed.ini", "PatientBilling", "N", "PBSLaunchIssueScreen", 0))) Then     '    "
      '16Nov99 SF added to stop the ecsd% code below firing if you you escape from the ques scroll
      If Val(Ques.Tag) = 0 Then
         Unload Ques
         GoTo PatientBillingExit
      End If
      '16Nov99 SF -----
      Unload Ques
   End If
                             
   If escd% Then
         ' ensure patient billing info reinstated for next issue
      If Not blnPBSEditFromDispens Then        '31Jan03 TH (PBSv4)  Skip this if just here to edit
         'If L.batchnumber > 0 Then L.batchnumber = L.batchnumber - 1
         'If L.batchnumber = 0 And PBSItemStatus$ <> "D" Then
         If blnContinue And blnQuesTag Then '03Jun07 TH added
            If m_PBSDrugRepeat.NumberOfIssues > 0 Then m_PBSDrugRepeat.NumberOfIssues = m_PBSDrugRepeat.NumberOfIssues - 1
            If m_PBSDrugRepeat.NumberOfIssues = 0 And PBSItemStatus$ <> "D" Then
            
               'sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & labf& & ";"
   ''                           sql$ = "DELETE * FROM drugrepeats WHERE drugrepeats.patrecno = '" & pid.recno & "' AND drugrepeats.rxnumber =" & Format$(L.prescriptionid) & ";"
   ''                           WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
   ''                           Patdb.Execute (sql$): DoSaferEvents 1
''               popmessagecr "TO DO", "Delete from Repeats"
''               If m_PBSDrugRepeat.NumberOfIssues = 0 Then
''                  'Here we will UPDATE the repeats table as required for deletions where we have no recorded issue
''                   NO we ignore anything important anyway on initialise if number of issues is zero !
''               End If
            End If
            If PBSItemStatus$ = "D" Then     ' deferred item
               'L.batchnumber = L.batchnumber - 1
               'If L.batchnumber < 0 Then L.batchnumber = 0
               m_PBSDrugRepeat.NumberOfIssues = m_PBSDrugRepeat.NumberOfIssues - 1
               If m_PBSDrugRepeat.NumberOfIssues < 0 Then m_PBSDrugRepeat.NumberOfIssues = 0
            End If
         End If '03Jun07 TH added
      End If                                   '   "
   End If


PatientBillingExit:
   On Error GoTo 0
   Exit Sub

PatientBillingErr:
   myError$ = Trim$(Error$)
   myErr = Err
   FatalErr% = True
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: PatientBilling) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & Error$ & cr & "Error number: " & myErr               '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: PatientBilling) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & myError$ & cr & "Error number: " & myErr   '16May00 SF
   'popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: PatientBilling" & cr & "Error: " & Error$ & cr & "Error number: " & myErr     '16May00 SF replaced
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: PatientBilling" & cr & "Error: " & myError$ & cr & "Error number: " & myErr    '16May00 SF
   Resume PatientBillingExit

End Sub

Private Sub PBSItemBillCalcs(prescriptionOwed As Integer, escd As Integer)


Dim markup!, dispensingFee!, dangerousdrugfee!, multiplier%  '08Mar03 TH/ATW REmoved , therapueticpremium! additionalFees!, brandpremium!,
Dim txt$, tmp$, debugMarkup$, additionalFee!, allowableFee!, compositeFee!  '08Mar03 TH/ATW REmoved cost1$, cost2$, cost3$, sql$,
Dim myError$, myErr%, fullPackQty!, wastage!, wastageAmount!, wastageCost!, wastagePremiums!, containerPrice!, contributions!, water%, EP%, WaterFee! '08Mar03 TH/ATW REmoved premiums!,
'Dim wastageFacor%()  '08Mar03 TH/ATW REmoved
Dim restriction$     '16Nov00 SF added
Dim BrandPremiums$                                                         '31Jan93 TH (PBSv4)
Dim Contributionwastagepremiums!, TherapueticPremiums$                     '    "
Dim DangerousDrugCode$                                                     '    "
Dim blnDrsBag As Integer                                                   '    "  Added as flag for Drs Bag
Dim intInjectableStartRange As Integer, intInjectableEndRange As Integer   '    "


   On Error GoTo PBSItemBillCalcsErr

   If PBSItemType$ = "P" And UCase$(Trim$(Billitems$(53))) = "R" Then                     '24Mar03 TH (PBSv4) Added
      '01Jun07 TH L.batchnumber = L.batchnumber + (Val(Billitems$(11)) + 1)    ' original + #repeats  '    "
     m_PBSDrugRepeat.NumberOfIssues = m_PBSDrugRepeat.NumberOfIssues + (Val(Billitems$(11)) + 1)    ' original + #repeats  '    "
   Else                                                                                   '    "
      '01Jun07 TH L.batchnumber = L.batchnumber + 1                                                   '    "
      m_PBSDrugRepeat.NumberOfIssues = m_PBSDrugRepeat.NumberOfIssues + 1                                                   '    "
   End If                                                                                 '    "

   hicprice! = 0

   BrandPremiums$ = "0.00"  '31Jan93 TH (PBSv4) Initialise Brandpremium
   'Need to check if this is a private or not
   If m_blnPBSPrivateDispensing Then PBSItemType$ = "N"   '09Mar03 TH (PBSv4) Added
   m_blnPBSPrivateDispensing = False                      '    "
   'If Trim$(UCase$(Billitems$(92))) = "Y" Then PBSItemType$ = "N"   '31Mar03 TH (PBSv4) Added for exceptional items
   If Trim$(UCase$(Billitems$(53))) = "X" Then
      PBSItemType$ = "N"     '01Apr03 TH Replaced
      multiplier = 1         '07Apr03 TH Added
   End If


   If PBSItemType$ = "P" Then
         '16Nov00 SF re-wrote how to handle EP items
         'If EPitem And (Not foundDrugItem) Then
         '      ' an EP item using average pricing
         '      ans$ = Format$(snpDrug!maxpricepayable)
         '      If Val(ans$) = 0 Then
         '            txt$ = "There are no Standard Formulae items in this group on which to base" & cr
         '            txt$ = txt$ & "the average price, please supply the dispensed price in $"
         '         Else
         '            txt$ = "This is the average price($) for items in this group" & cr
         '            txt$ = txt$ & "you may overwrite it with a higher price if necessary"
         '         End If
         '
         '      'k.nums = True
         '      inputwin "Patient Billing", txt$, ans$, k
         '      If k.escd Then
         '            escd = True
         '            Exit Sub
         '         End If
         '   End If
         If EPItem Then
               If foundDrugitem Then
                     txt$ = "The average price for items in the group selected will be used." & cr
                     txt$ = txt$ & "You may overwrite on the next screen if necessary."
                  Else
                     txt$ = "As a standard formulae item was not selected, you will" & cr
                     txt$ = txt$ & "need to enter the cost to the patient and how much will" & cr
                     txt$ = txt$ & "be recorded against the patient's PRF on the next screen."
                  End If
               popmessagecr "#Patient Billing", txt$
            End If
         '16Nov00 SF -----

         ' some RP items need to charge as an EP item and/or an additional cost for adding water (eg. to powder)
         If foundDrugitem And (Not EPItem) Then
               ''popmessagecr "TO DO", "AddWaterCostEP"
               AddWaterCostEP water, EP
               If water Then
                     WaterFee! = m_PatFees.WaterFee - m_PatFees.CompositeFeeEP
                  Else
                     WaterFee! = 0
                  End If
            End If
         allowableFee! = m_PatFees.AllowableExtraFee
         
         ' different fees for RP and EP items
         If EPItem Or EP Then
               additionalFee! = m_PatFees.AdditionalFeeEP
               compositeFee! = m_PatFees.CompositeFeeEP
            Else
               additionalFee! = m_PatFees.AdditionalFeeRP
               compositeFee! = m_PatFees.CompositeFeeRP
            End If
         
         ' add an aditional fee if the drug is classed as dangerous (does not apply to EP items)
         '31Jan93 TH (PBSv4) Changed section to pick up codes
         dangerousdrugfee! = 0
         If Not EPItem Then
               DangerousDrugCode$ = Trim$(UCase$(TxtD(dispdata$ & BillIniFile$, "PBS", "", "DangerousDrugCode", 0)))
               If Trim$(DangerousDrugCode$) <> "" Then
                     If InStr(DangerousDrugCode$, ".") > 0 Then
                           If Trim$(UCase$(Left$(d.bnf, 8))) = DangerousDrugCode$ Then dangerousdrugfee! = m_PatFees.dangerousdrugfee
                        Else
                           If Trim$(UCase$(d.therapcode)) = DangerousDrugCode$ Then dangerousdrugfee! = m_PatFees.dangerousdrugfee
                        End If
                  End If
               'Select Case d.bnf
               '   Case "xx.xx": dangerousdrugfee! = getfield(patfees!dangerousdrugfee)
               '   Case Else: dangerousdrugfee! = 0
               'End Select
            End If
         '31Jan93 TH (PBSv4) Removed as already factored in earlier now.(v4)
         ''check if regulation 24 (ie. issue all in one go.  Original + #repeats)
         'If PBSitemStatus$ = "R" Then
         '      multiplier = (Val(billitems$(11)) + 1)    ' original + #repeats
         '      Qty! = Qty! * multiplier
         '      toDispens! = Qty!
         '   Else
         '      multiplier = 1
         '   End If
         If UCase$(Trim$(Billitems$(53))) = "R" Then
               multiplier = (Val(Billitems$(11)) + 1)    ' original + #repeats
               'Qty! = Qty! * multiplier     '31Jan93 TH (PBSv4) Already factored in
               toDispens! = Qty!
            Else
               multiplier = 1
            End If

      End If
   '31Jan93 TH (PBSv4) Added Block to set Markups
   If foundDrugitem And Not EPItem Then
      If InStr("," & Trim$(UCase$(m_PBSProduct.DrugTypeCode)) & ",", "," & Trim$(UCase$(TxtD(dispdata$ & BillIniFile$, "PBS", ",CS,CT,GH,HS,IF,MD,MF,SA,", "HSDTypes", 0))) & ",") > 0 Then
            m_sglLowMarkUpLevel = m_PatFees.HSDlowMarkupLevel
            m_sglMarkUpLow = m_PatFees.HSDmarkupLow
            m_sglHighMarkUpLevel = m_PatFees.HSDhighMarkupLevel
            m_sglMarkUpHigh = m_PatFees.HSDmarkupHigh
            m_sglMarkUpMid = m_PatFees.HSDmarkupMid
         Else
            m_sglLowMarkUpLevel = m_PatFees.PBSlowMarkupLevel
            m_sglMarkUpLow = m_PatFees.PBSmarkupLow
            m_sglHighMarkUpLevel = m_PatFees.PBShighMarkupLevel
            m_sglMarkUpHigh = m_PatFees.PBSmarkupHigh
            m_sglMarkUpMid = m_PatFees.PBSmarkupMid
         End If
      Else
         m_sglLowMarkUpLevel = m_PatFees.PBSlowMarkupLevel
         m_sglMarkUpLow = m_PatFees.PBSmarkupLow
         m_sglHighMarkUpLevel = m_PatFees.PBShighMarkupLevel
         m_sglMarkUpHigh = m_PatFees.PBSmarkupHigh
         m_sglMarkUpMid = m_PatFees.PBSmarkupMid
      End If
   '--------------------------
   
   If PBSItemType$ = "P" And (Not EPItem) And foundDrugitem = True Then
         '!!** need to read from MDB in case they change
         ReDim wastageFactor(20)
         wastageFactor(1) = 10
         wastageFactor(2) = 18
         wastageFactor(3) = 26
         wastageFactor(4) = 32
         wastageFactor(5) = 38
         wastageFactor(6) = 44
         wastageFactor(7) = 50
         wastageFactor(8) = 54
         wastageFactor(9) = 58
         wastageFactor(10) = 62
         wastageFactor(11) = 66
         wastageFactor(12) = 70
         wastageFactor(13) = 74
         wastageFactor(14) = 78
         wastageFactor(15) = 82
         wastageFactor(16) = 86
         wastageFactor(17) = 90
         wastageFactor(18) = 94
         wastageFactor(19) = 98
         wastageFactor(20) = 100
         
         fullPackQty! = Qty! \ m_PBSProduct.ROP
         wastageAmount! = Qty! Mod m_PBSProduct.ROP
         If Qty! < m_PBSProduct.ROP Then
               wastageAmount! = Qty!
               intInjectableStartRange = Int(Val(TxtD(dispdata$ & BillIniFile$, "PBS", "6500", "InjectableStartRange", 0)))   '31Jan93 TH (PBSv4) Make range configurable if necessary
               intInjectableEndRange = Int(Val(TxtD(dispdata$ & BillIniFile$, "PBS", "7300", "InjectableEndRange", 0)))       '    "
               If Val(m_PBSProduct.PBScode) < intInjectableEndRange And Val(m_PBSProduct.PBScode) > intInjectableStartRange Then  '31Jan93 TH (PBSv4) Items falling within this range are considered as injectable items
                     containerPrice! = m_PatFees.InjectableContainerPrice                                                      '    "      and use a seperate container value. The PBS code range can be configured if necessary
                  Else                                                                                                                      '    "      (Defaults correct as at FEB 2002)
               containerPrice! = m_PatFees.containerPrice
                  End If                                                                                                                    '    "
            Else
               containerPrice! = 0
            End If
         If wastageAmount! > 0 Then
               wastagePremiums! = 0
               wastage! = (100 / m_PBSProduct.ROP) * wastageAmount!
               '31Jan93 TH (PBSv4) Added Calculation of Contributionwastagepremiums!
               Select Case wastage!
                  Case Is <= 5:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice / 100) * wastageFactor(1)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(1)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(1)
                        End If
                  Case Is <= 10:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(2)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(2)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(2)
                        End If
                  Case Is <= 15:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(3)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(3)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(3)
                        End If
                  Case Is <= 20:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(4)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(4)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(4)
                        End If
                  Case Is <= 25:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(5)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(5)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(5)
                        End If
                  Case Is <= 30:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(6)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(6)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(6)
                        End If
                  Case Is <= 35:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(7)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(7)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(7)
                        End If
                  Case Is <= 40:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(8)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(8)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(8)
                        End If
                  Case Is <= 45:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(9)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(9)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(9)
                        End If
                  Case Is <= 50:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(10)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(10)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(10)
                        End If
                  Case Is <= 55:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(11)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(11)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(11)
                        End If
                  Case Is <= 60:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(12)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(12)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(12)
                        End If
                  Case Is <= 65:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(13)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(13)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(13)
                        End If
                  Case Is <= 70:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(14)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(14)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(14)
                        End If
                  Case Is <= 75:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(15)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(15)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(15)
                        End If
                  Case Is <= 80:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(16)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(16)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(16)
                        End If
                  Case Is <= 85:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(17)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(17)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(17)
                        End If
                  Case Is <= 90:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(18)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(18)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(18)
                        End If
                  Case Is <= 95:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(19)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(19)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(19)
                        End If
                  Case Is <= 100:
                     wastageCost! = (m_PBSProduct.CommonWealthPrice) / 100 * wastageFactor(20)
                     If m_PBSProduct.PriceToPharmacy > 0 Then
                           wastagePremiums! = (m_PBSProduct.PriceToPharmacy / 100) * wastageFactor(20)
                           Contributionwastagepremiums! = ((m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice) / 100) * wastageFactor(20)
                        End If
               End Select
            Else
               wastageCost! = 0
            End If
      End If

   'If PBSitemType$ = "N" Then                                        '31Jan93 TH (PBSv4)
   If PBSItemType$ = "N" Or Trim$(UCase$(Billitems$(53))) = "N" Then  '    "
         ' work out the price for private dispensing
         markup! = m_PatFees.PrivateMarkup                      ' in %
         dispensingFee! = m_PatFees.PrivateDispensingFee      ' in $
         '16Nov00 SF added the following code to allow DispensedPriceMaxQty to be used or d.cost
         If (Not EPItem) And (foundDrugitem) Then
               If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "UseDispensedPriceMaxQty", 0)) Then
                     PatientCost! = ((m_PBSProduct.CommonWealthDispensed / Val(d.convfact))) * Qty!
                  Else
                     PatientCost! = ((Val(d.cost) / Val(d.convfact)) / 100) * Qty!
                  End If
            Else
               '16Nov00 SF moved the following statement into the IF statement
               PatientCost! = ((Val(d.cost) / Val(d.convfact)) / 100) * Qty!
            End If
         '16Nov00 SF -----
         PatientCost! = (PatientCost! * markup!) + dispensingFee!
         SafetyNetValue! = 0
      ElseIf PBSItemType$ = "P" And (Not foundDrugitem) And (Not EPItem) Then
         ' drug not in PBS/RPBS schedule but DVA approved for repatriation patients
         If Trim$(safetyNetCard$) <> "" Then
               PatientCost! = m_PatFees.SafetyNetEntitlement
            Else
               PatientCost! = m_PatFees.ConcessionPatient
            End If
         SafetyNetValue! = PatientCost!
         hicprice! = ((Val(d.cost) / Val(d.convfact)) / 100) * Qty!
         'If hicprice! <= getfield(patfees!PBSLowMarkUpLevel) Then           '31Jan93 TH (PBSv4) Use new markup variables set above
         '      hicprice! = hicprice! * getfield(patfees!PBSMarkUpLow)       '    "
         '   ElseIf hicprice! > getfield(patfees!PBSHighMarkUpLevel) Then    '    "
         '      hicprice! = hicprice! * getfield(patfees!PBSMarkUpHigh)      '    "
         '   Else                                                            '    "
         '      hicprice! = hicprice! + getfield(patfees!PBSMarkUpMid)       '    "
         '   End If                                                          '    "
         If hicprice! <= m_sglLowMarkUpLevel Then                            '    "
               hicprice! = hicprice! * m_sglMarkUpLow                        '    "
            ElseIf hicprice! > m_sglHighMarkUpLevel Then                     '    "
               hicprice! = hicprice! * m_sglMarkUpHigh                       '    "
            Else                                                             '    "
               hicprice! = hicprice! + m_sglMarkUpMid                        '    "
            End If                                                           '    "
         hicprice! = hicprice! + compositeFee!
         Transcost! = hicprice!  '31Jan93 TH (PBSv4) Added
      Else
         ' work out the price for PBS dispensing
         Select Case BeneficiaryType$
            ' general patient
            Case "G":
               If Not EPItem Then
                     If Trim$(safetyNetCard$) <> "" Then
                           PatientCost! = m_PatFees.SafetyNetConcession * multiplier
                           SafetyNetValue! = PatientCost!
                           GetTransactionCost additionalFee!, allowableFee!, multiplier, fullPackQty!, Qty!, wastageCost!, wastagePremiums!, compositeFee!, dangerousdrugfee!, containerPrice!, WaterFee! '20Aug01 TH %PBS%
                        Else
                           'If getfield(snpdrug!pricetopharmacy) = 0 Then             '31Jan93 TH (PBSv4) Always use commonwealth price here
                                 'PatientCost! = getfield(snpDrug!commonwealthprice)
                                 PatientCost! = m_PBSProduct.CommonWealthPrice * multiplier  '24Mar03 TH Added Multiplier for Reg24 (PBSv4)
                           '   Else                                                   '   "       As Brand Premium is calculated later
                           '      PatientCost! = getfield(snpdrug!pricetopharmacy)    '   "
                           '   End If                                                 '   "
                           SafetyNetValue! = m_PBSProduct.CommonWealthPrice
                           '31Jan93 TH (PBSv4) Moved block below markup to match PBS examples
                           'If Qty! < getfield(snpDrug!ROP) Then
                           '      PatientCost! = wastageCost! + wastagePremiums!
                           '      SafetyNetValue! = wastageCost!
                           '   Else
                           '      PatientCost! = (PatientCost! / getfield(snpDrug!maxqty)) * (fullPackQty! * getfield(snpDrug!maxqty))
                           '      'PatientCost! = Val(Format(CStr((PatientCost! / getfield(snpDrug!maxqty))), "###.00")) * (fullPackQty! * getfield(snpDrug!maxqty))
                           '      'PatientCost! = (PatientCost!) * (fullPackQty!)
                           '      PatientCost! = PatientCost! + wastageCost! + wastagePremiums!
                           '      SafetyNetValue! = (SafetyNetValue! / getfield(snpDrug!maxqty)) * (fullPackQty! * getfield(snpDrug!maxqty))
                           '      SafetyNetValue! = SafetyNetValue! + wastageCost!
                           '   End If
                           
                           'If multiplier > 1 Or PatientCost! <= getfield(patfees!PBSLowMarkUpLevel) Then      '31Jan93 TH (PBSv4) Use new markup variables set above
                           '      PatientCost! = PatientCost! * getfield(patfees!PBSMarkUpLow)                 '    "
                           '      SafetyNetValue! = SafetyNetValue! * getfield(patfees!PBSMarkUpLow)           '    "
                           '      debugMarkup$ = Format$(getfield(patfees!PBSMarkUpLow) * 100 - 100) & "%"     '    "
                           '   ElseIf PatientCost! > getfield(patfees!PBSHighMarkUpLevel) Then                 '    "
                           '      PatientCost! = PatientCost! * getfield(patfees!PBSMarkUpHigh)                '    "
                           '      SafetyNetValue! = SafetyNetValue! * getfield(patfees!PBSMarkUpHigh)          '    "
                           '      debugMarkup$ = Format$(getfield(patfees!PBSMarkUpHigh) * 100 - 100) & "%"    '    "
                           '   Else                                                                            '    "
                           '      PatientCost! = PatientCost! + getfield(patfees!PBSMarkUpMid)                 '    "
                           '      SafetyNetValue! = SafetyNetValue! + getfield(patfees!PBSMarkUpMid)           '    "
                           '      debugMarkup$ = "$" & Format$(getfield(patfees!PBSMarkUpMid))                 '    "
                           '   End If                                                                          '    "
                           If multiplier > 1 Or PatientCost! <= m_sglLowMarkUpLevel Then                       '    "
                                 PatientCost! = PatientCost! * m_sglMarkUpLow                                  '    "

                                 SafetyNetValue! = SafetyNetValue! * m_sglMarkUpLow                            '    "
                              ElseIf PatientCost! > m_sglHighMarkUpLevel Then                                  '    "
                                 PatientCost! = PatientCost! * m_sglMarkUpHigh                                 '    "
                                 SafetyNetValue! = SafetyNetValue! * m_sglMarkUpHigh                           '    "
                              Else                                                                             '    "
                                 PatientCost! = PatientCost! + m_sglMarkUpMid                                  '    "
                                 SafetyNetValue! = SafetyNetValue! + m_sglMarkUpMid                            '    "
                              End If                                                                           '    "
                           PatientCost! = Val(Format(CStr(PatientCost!), "#.00"))        '31Jan93 TH (PBSv4) Added
                           SafetyNetValue! = Val(Format(CStr(SafetyNetValue!), "#.00"))  '    "
                           
                           If Qty! < m_PBSProduct.ROP Then
                                 PatientCost! = wastageCost! + wastagePremiums!
                                 SafetyNetValue! = wastageCost!
                              Else
                                 PatientCost! = (PatientCost! / m_PBSProduct.maxqty) * (fullPackQty! * m_PBSProduct.maxqty)
                                 PatientCost! = PatientCost! + wastageCost! + wastagePremiums!
                                 SafetyNetValue! = (SafetyNetValue! / m_PBSProduct.maxqty) * (fullPackQty! * m_PBSProduct.maxqty)
                                 SafetyNetValue! = SafetyNetValue! + wastageCost!
                              End If
                           '31Jan93 TH (PBSv4) Set these here now
                           If multiplier > 1 Or PatientCost! <= m_sglLowMarkUpLevel Then                       '    "
                                 debugMarkup$ = Format$(m_sglMarkUpLow * 100 - 100) & "%"                      '    "
                              ElseIf PatientCost! > m_sglHighMarkUpLevel Then                                  '    "
                                 debugMarkup$ = Format$(m_sglMarkUpHigh * 100 - 100) & "%"                     '    "
                              Else                                                                             '    "
                                 debugMarkup$ = "$" & Format$(m_sglMarkUpMid)                                  '    "
                              End If                                                                           '    "
                           
                           PatientCost! = PatientCost! + compositeFee!
                           SafetyNetValue! = SafetyNetValue! + compositeFee!
                           PatientCost! = PatientCost! + dangerousdrugfee!
                           SafetyNetValue! = SafetyNetValue! + dangerousdrugfee!
                           PatientCost! = PatientCost! + containerPrice!
                           SafetyNetValue! = SafetyNetValue! + containerPrice!      '? not sure whether counted in safety net
                           PatientCost! = PatientCost! + WaterFee!
                           SafetyNetValue! = SafetyNetValue! + WaterFee!
                     Transcost! = PatientCost!   '31Jan93 TH (PBSv4) Added  Added
                     ' add additional fee for recording on PRF if it doesn't take cost over $20.30 otherwise cap at $20.30
                     If PatientCost! + additionalFee! > m_PatFees.GeneralPatient Then
                           SafetyNetValue! = SafetyNetValue! + (m_PatFees.GeneralPatient - PatientCost!)
                           'PatientCost! = getfield(patfees!GeneralPatient)                 '24Mar03 TH (PBSv4) Include multiplier for Reg24
                           PatientCost! = m_PatFees.GeneralPatient * multiplier     '   "
                        Else
                           PatientCost! = PatientCost! + additionalFee!
                           SafetyNetValue! = SafetyNetValue! + additionalFee!
                        End If
                     
                     ' add allowable extra fee if it doesn't take cost over $20.30 otherwise cap at $20.30
                     If PatientCost! + allowableFee! > m_PatFees.GeneralPatient Then
                           'PatientCost! = getfield(patfees!GeneralPatient)                   '24Mar03 TH (PBSv4) Include multiplier for Reg24
                           PatientCost! = m_PatFees.GeneralPatient * multiplier       '   "
                           'SafetyNetValue! = getfield(patfees!GeneralPatient)                '   "
                           SafetyNetValue! = m_PatFees.GeneralPatient * multiplier    '   "
                        Else
                           PatientCost! = PatientCost! + allowableFee!
                        End If
                     Transcost! = Transcost! + allowableFee! + additionalFee!      '31Jan93 TH (PBSv4) Added
                     'Add in Brandpremium properly costed against qty with wastage factor and markup etc.
                     CalculateContributions PatientCost!, BrandPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier%        '31Jan93 TH (PBSv4) Added  Added
                     CalcTherapueticPremiums PatientCost!, TherapueticPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier% '    "
                  End If
               Else
                  If EPItem = -1 Then
                        ' using average EP pricing
                        'PatientCost! = Val(ans$) * multiplier                                  '25Mar03 TH (PBSv4) Replaced
                        PatientCost! = Val(m_PBSProduct.MaxPricePayable) * multiplier      '    "
                        'If PatientCost! > (m_PBSProduct.maxpricepayable * multiplier) Then hicprice! = PatientCost!   '25Mar03 TH (PBSv4) Removed
                        SafetyNetValue! = m_PBSProduct.MaxPriceToPatients
                        
                        Transcost! = PatientCost!   '20Aug01 TH %PBS% Added
                        
                        ' add additional fee for recording on PRF if it doesn't take cost over $20.30 otherwise cap at $20.30
                        If PatientCost! + additionalFee! > m_PatFees.GeneralPatient Then
                              'safetyNetValue! = safetyNetValue! + (getfield(patfees!GeneralPatient) - patientCost!)
                              PatientCost! = m_PatFees.GeneralPatient
                           Else
                              PatientCost! = PatientCost! + additionalFee!
                              'safetyNetValue! = safetyNetValue! + additionalFee!
                           End If
                        
                        ' add allowable extra fee if it doesn't take cost over $20.30 otherwise cap at $20.30
                        If PatientCost! + allowableFee! > m_PatFees.GeneralPatient Then
                              PatientCost! = m_PatFees.GeneralPatient
                              'safetyNetValue! = getfield(patfees!GeneralPatient)
                           Else
                              PatientCost! = PatientCost! + allowableFee!
                           End If
                        
                        Transcost! = Transcost! + allowableFee! + additionalFee!      '31Jan93 TH (PBSv4) Added
                     Else
                        ' using a standard EP formulae
                     End If
               End If
            
            ' concession card
            Case "C", "R":
               If Trim$(safetyNetCard$) <> "" Then
                     PatientCost! = m_PatFees.SafetyNetEntitlement * multiplier
                     SafetyNetValue! = PatientCost!
                     If Not EPItem Then
                           GetTransactionCost additionalFee!, allowableFee!, multiplier, fullPackQty!, Qty!, wastageCost!, wastagePremiums!, compositeFee!, dangerousdrugfee!, containerPrice!, WaterFee!
                           CalculateContributions PatientCost!, BrandPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier%  '31Jan93 TH (PBSv4) Added
                           'If getfield(snpdrug!pricetopharmacy) > 0 Then
                           '      contributions! = getfield(snpdrug!pricetopharmacy) - getfield(snpdrug!commonwealthprice)
                           '      'contributions! = (contributions! * fullPackQty) + wastagePremiums!              '15Aug01 TH Add in only wastage factor for contirbutable
                           '      contributions! = (contributions! * fullPackQty) + Contributionwastagepremiums!   '           amount (ie Brand Premium)
                           '      contributions! = contributions! * multiplier
                           '      If multiplier > 1 Or PatientCost! <= getfield(patfees!PBSlowMarkupLevel) Then
                           '            contributions! = contributions! * getfield(patfees!PBSmarkupLow)
                           '            debugMarkup$ = Format$(getfield(patfees!PBSmarkupLow) * 100 - 100) & "%"
                           '         ElseIf PatientCost! > getfield(patfees!PBShighMarkupLevel) Then
                           '            contributions! = contributions! * getfield(patfees!PBSmarkupHigh)
                           '            debugMarkup$ = Format$(getfield(patfees!PBSmarkupHigh) * 100 - 100) & "%"
                           '         Else
                           '            contributions! = contributions! + getfield(patfees!PBSmarkupMid)
                           '            debugMarkup$ = "$" & Format$(getfield(patfees!PBSmarkupMid))
                           '         End If
                           '      contributions! = (Int(contributions! * 100) / 100) '13Aug01 TH %PBS% Convoluted way of rounding off   '!!!Surely NO
                           '      PatientCost! = PatientCost! + contributions!
                           '      BrandPremiums$ = Format$(contributions!)'13Aug01 TH %PBS%
                           '   End If
                           CalcTherapueticPremiums PatientCost!, TherapueticPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier% '31Jan93 TH (PBSv4) Replaced above
                        Else
                           'If Val(ans$) > (getfield(snpDrug!maxpricepayable) * multiplier) Then hicprice! = Val(ans$)  '25Mar03 TH (PBSv4) Removed
                        End If
                  Else
                     PatientCost! = m_PatFees.ConcessionPatient * multiplier
                     SafetyNetValue! = PatientCost!
                     If Not EPItem Then
                           GetTransactionCost additionalFee!, allowableFee!, multiplier, fullPackQty!, Qty!, wastageCost!, wastagePremiums!, compositeFee!, dangerousdrugfee!, containerPrice!, WaterFee!
                           CalculateContributions PatientCost!, BrandPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier%
                           'If getfield(snpdrug!pricetopharmacy) > 0 Then
                           '      contributions! = getfield(snpdrug!pricetopharmacy) - getfield(snpdrug!commonwealthprice)
                           '      'contributions! = (contributions! * fullPackQty) + wastagePremiums!
                           '      contributions! = (contributions! * fullPackQty) + Contributionwastagepremiums!
                           '      contributions! = contributions! * multiplier
                           '      If multiplier > 1 Or PatientCost! <= getfield(patfees!PBSlowMarkupLevel) Then
                           '            contributions! = contributions! * getfield(patfees!PBSmarkupLow)
                           '            'Contributionwastagepremiums! = Contributionwastagepremiums! * getfield(patfees!PBSmarkupLow)
                           '            debugMarkup$ = Format$(getfield(patfees!PBSmarkupLow) * 100 - 100) & "%"
                           '         ElseIf PatientCost! > getfield(patfees!PBShighMarkupLevel) Then
                           '            contributions! = contributions! * getfield(patfees!PBSmarkupHigh)
                           '            'Contributionwastagepremiums! = Contributionwastagepremiums! * getfield(patfees!PBSmarkupHigh)
                           '            debugMarkup$ = Format$(getfield(patfees!PBSmarkupHigh) * 100 - 100) & "%"
                           '         Else
                           '            contributions! = contributions! + getfield(patfees!PBSmarkupMid)
                           '            'Contributionwastagepremiums! = Contributionwastagepremiums! * getfield(patfees!PBSmarkupMid)
                           '            debugMarkup$ = "$" & Format$(getfield(patfees!PBSmarkupMid))
                           '         End If
                           '      'contributions! = (Int(contributions! * 100) / 100) '13Aug01 TH %PBS% Convoluted way of rounding off   '!!!Surely NO
                           '      'contributions! = (Int(contributions! * 100) / 100)
                           '      PatientCost! = PatientCost! + contributions!
                           '      BrandPremiums$ = Format$((contributions! - .001))'13Aug01 TH %PBS%
                           '      'poundsandpence BrandPremiums$, False
                           '      'BrandPremiums$ = Format$(Int(contributions! * 100) / 100)'13Aug01 TH %PBS% Convoluted way of rounding off
                           '   End If
                           CalcTherapueticPremiums PatientCost!, TherapueticPremiums$, debugMarkup$, fullPackQty, Contributionwastagepremiums!, multiplier% '31Jan93 TH (PBSv4) Replace above
                        Else
                           If foundDrugitem Then
                                 ' 16Nov00 SF moved into IF statement to ensure object set
                                 'If Val(ans$) > (getfield(snpDrug!maxpricepayable) * multiplier) Then hicprice! = Val(ans$)  '25Mar03 TH (PBSv4) Removed
                              End If
                        End If
                  End If
         End Select
         
      End If

   If Not blnAddToPRF Then SafetyNetValue! = 0     '24Nov99 SF if patient category means that the patient doesn't pay then 0 the safety net value
   If InStr(UCase$(Command$), "/PBSDEBUG") Then GoSub PBSBillingDebug   ' used for debug mode only
   If foundDrugitem And Not EPItem Then                                   '31Jan93 TH (PBSv4) Dont let EPitems in here (they cant then be DR Bags)
      If Trim$(UCase$(m_PBSProduct.DrugTypeCode)) = "DB" Then            '31Jan93 TH (PBSv4)
            blnDrsBag = True                                                  '    "
            PatientCost! = 0                                                  '    "
            SafetyNetValue! = 0                                               '    "
         End If                                                               '    "
   End If                                                                     '    "
   PBSdebug BrandPremiums$, escd%    '31Jan93 TH (PBSv4) Added cancel option

   If (escd) Then
      'l.batchnumber = l.batchnumber - 1    '31Jan93 TH (PBSv4) Added
      '01Jun07 TH L.batchnumber = L.batchnumber - (1 * multiplier)     '24Mar03 TH Added multiplier
      m_PBSDrugRepeat.NumberOfIssues = m_PBSDrugRepeat.NumberOfIssues - (1 * multiplier)     '24Mar03 TH Added multiplier
      
      'Reset repeats on escape ?
      GoTo PBSItemBillCalcsExit            '    "
   End If
   

   '02Dec99 SF added to update serial number for PBS items that we need to make a claim from HIC
   If (Trim$(UCase$(Billitems$(53))) <> "X") Then  '01Apr03 TH Added
      If PBSItemType$ = "P" And Billitems$(53) <> "N" Then
         safeNet = False
         If (BeneficiaryType$ = "G") And (Trim$(safetyNetCard$) = "") And (Not escd) Then
            ' a general patient
            If Trim$(debugPatientCost$) <> "" Then               '   "
               ' user over-ridden calculated cost
               tmp$ = debugPatientCost$
            Else
               ' use calculated cost
               tmp$ = Format$(PatientCost!)
            End If
            If Val(tmp$) < Transcost! Then                     '01Mar03 TH (PBSv4) Replaced If transcost is > pat contribution then there will be a claim
                  If PBSItemStatus$ <> "O" Then
                     'popmessagecr "TO DO", "UpdateSerialNumber"
                     UpdateSerialNumber serialnumber&, 0, "", ""   '14Jul03 TH Added params
                  End If
            Else
               safeNet = True
            End If
         Else
            ' any other benefit patient
            If PBSItemStatus$ <> "O" Then
               'popmessagecr "TO DO", "UpdateSerialNumber"
               UpdateSerialNumber serialnumber, 0, "", ""    '14Jul03 TH Added params
            End If
         End If
         ' serialNumWithPrefix$ used for HIC claim and printed on documentation etc.
         If Not safeNet Then  '22Feb03 TH(PBSv4) If No serial no then no prefix required ?
            If PBSItemStatus$ = "O" Then
               serialNumWithPrefix$ = "RxOwed"
            Else
               'serialNumWithPrefix$ = GetSerialPrefix()            '31Jan93 TH (PBSv4) Added Parameter for DRs Bag
               'popmessagecr "TO DO", "GetSerialPrefix"
               serialNumWithPrefix$ = GetSerialPrefix(blnDrsBag, "", "")  '   "      '15Jul03 TH Added Extra params
               serialNumWithPrefix$ = serialNumWithPrefix$ & Format$(serialnumber&)
               restriction$ = ""
               If Trim$(SpecialAuthorityNum$) <> "" Then restriction$ = "A"
               If (Not EPItem) And (foundDrugitem) And (restriction$ = "") Then restriction$ = UCase$(Trim$(m_PBSProduct.RestrictionFlag))
               If restriction$ = "A" Then serialNumWithPrefix$ = "A" & serialNumWithPrefix$        ' authority item
               If PBSItemStatus$ = "D" Then serialNumWithPrefix$ = "D" & serialNumWithPrefix$      ' deferred item
            End If
         Else
            serialNumWithPrefix$ = ""
         End If
      Else
         ' paid less than < $20.30 so no claim to HIC and serial number not needed
         safeNet = True
         serialNumWithPrefix$ = ""   '22Feb03 TH(PBSv4) No serial prefix if no claim to HIC
      End If
   Else
      'popmessagecr "TO DO", "UpdateSerialNumber"
      UpdateSerialNumber serialnumber&, 0, "", ""    '14Jul03 TH Added params
      'popmessagecr "TO DO", "GetSerialPrefix"
      'serialNumWithPrefix$ = GetSerialPrefix(blnDrsBag, "", "")  '   " '15Jul03 TH Added Extra params     '24Jul03 TH Replaced as all Exceptionals are Authority (?-Apparently)
      serialNumWithPrefix$ = "A"                                                                           '     "
      serialNumWithPrefix$ = serialNumWithPrefix$ & Format$(serialnumber&)
      If (Not EPItem) And (foundDrugitem) And (restriction$ = "") Then restriction$ = UCase$(Trim$(m_PBSProduct.RestrictionFlag))  '24Jul03 TH Removed
      If restriction$ = "A" Then serialNumWithPrefix$ = "A" & serialNumWithPrefix$        ' authority item                              '     "
   End If
    
   If (Not escd) And (Not prescriptionOwed) Then
      transCount = transCount + 1
      ''popmessagecr "TO DO", "ParsePatientBill"
      ParsePatientBill 0, transCount, False, True
   End If


PBSItemBillCalcsExit:
   On Error GoTo 0
   Exit Sub

PBSItemBillCalcsErr:
   FatalErr% = True
   myError$ = Trim$(Error$)
   myErr = Err
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: PBSItemBillCalcs) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & myError$ & cr & "Error number: " & Format$(myErr)              '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: PBSItemBillCalcs) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & myError$ & cr & "Error number: " & Format$(myErr)    '16May00 SF
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: PBSItemBillCalcs" & cr & "Error: " & myError$ & cr & "Error number: " & Format$(myErr)
   Resume PBSItemBillCalcsExit

PBSBillingDebug:
   'txt$ = "Debug info for: " & Format$(Qty!) & " " & Trim$(d.PrintformV) & " " & d.SisCode & " " & Trim$(d.Description) & cr & cr  XN 4Jun15 98073 New local stores description
   txt$ = "Debug info for: " & Format$(Qty!) & " " & Trim$(d.PrintformV) & " " & d.SisCode & " " & Trim$(d.LabelDescription) & cr & cr
   If PBSItemType$ = "N" Then
         ' private patient
         txt$ = txt$ & "Item type:" & TB & TB & TB & "Private" & cr
         txt$ = txt$ & "Cost per pack:" & TB & TB & "$" & Format$(Val(d.cost) / 100) & cr
         txt$ = txt$ & "GST code:" & TB & TB & Format$(d.vatrate) & cr
         txt$ = txt$ & "Pack size:" & TB & TB & Format$(d.convfact) & cr
         txt$ = txt$ & "Dispensing fee:" & TB & TB & "$" & Format$(dispensingFee!) & cr & cr
      Else
         ' pbs patient
         txt$ = txt$ & "Item type:" & TB & TB & TB & TB & "PBS Dispensing" & cr
         txt$ = txt$ & "PBS/Manu. Code:" & TB & TB & TB & Trim$(m_PBSProduct.PBScode) & " " & Trim$(m_PBSProduct.ManufacturersCode) & cr
         If Trim$(safetyNetCard$) <> "" Then
               txt$ = txt$ & "Safety Net Card Type:" & TB & TB & TB & safetyNetCard$ & cr & cr
            Else
               txt$ = txt$ & "Beneficiary Type:" & TB & TB & TB & BeneficiaryType$ & cr & cr
            End If
         txt$ = txt$ & "Commonwealth Price:" & TB & TB & "$" & Format$(m_PBSProduct.CommonWealthPrice) & cr
         txt$ = txt$ & "Cost to pharmacy:" & TB & TB & TB & "$" & Format$(m_PBSProduct.PriceToPharmacy) & cr
         txt$ = txt$ & "Markup:" & TB & TB & TB & TB & debugMarkup$ & cr & cr
         txt$ = txt$ & "Max. S.N. Recoradable:" & TB & TB & "$" & Format$(m_PBSProduct.MaxRecordableValue) & cr
         txt$ = txt$ & "Composite Fee:" & TB & TB & TB & "$" & Format$(compositeFee!) & cr
         txt$ = txt$ & "Additional Fee:" & TB & TB & TB & "$" & Format$(additionalFee!) & cr
         txt$ = txt$ & "Allowable Extra Fee:" & TB & TB & "$" & Format$(allowableFee!) & cr
         txt$ = txt$ & "Water Fee:" & TB & TB & TB & "$" & Format$(WaterFee!) & cr
         txt$ = txt$ & "Dangerous Drug Fee:" & TB & TB & "$" & Format$(dangerousdrugfee!) & cr
         txt$ = txt$ & "Container Price:" & TB & TB & TB & "$" & Format$(containerPrice!) & cr
         txt$ = txt$ & "Additional wastage:" & TB & TB & TB & "$" & Format$(wastageCost!) & cr
         If Trim$(SpecialAuthorityNum$) <> "" Then
               txt$ = txt$ & "Authority?:" & TB & TB & TB & "Yes" & cr
            Else
               txt$ = txt$ & "Authority?:" & TB & TB & TB & "No" & cr
            End If
         If multiplier > 1 Then
               txt$ = txt$ & "Regulation24?:" & TB & TB & TB & "Yes" & cr
            Else
               txt$ = txt$ & "Regulation24?:" & TB & TB & TB & "No" & cr
            End If
      End If

   popmessagecr "Patient Billing", txt$
   Return

End Sub
Sub GetTransactionCost(additionalFee!, allowableFee!, multiplier, fullPackQty!, Qty!, wastageCost!, wastagePremiums!, compositeFee!, dangerousdrugfee!, containerPrice!, WaterFee!)
'31Jan03 TH (PBSv4) Written
'31Jan03 TH (PBSv4) Added new markup differentiation for HSD items - modular level vars should have been set already through PBSItemBillCalcs
'   "               So never call this without ensuring these vars are set correctly first !
'31Jan03 TH (PBSv4) MERGED

   Transcost! = m_PBSProduct.CommonWealthPrice
      
   If Qty! < m_PBSProduct.ROP Then
         Transcost! = wastageCost! + wastagePremiums!
      Else
         Transcost! = (Transcost! / m_PBSProduct.maxqty) * (fullPackQty! * m_PBSProduct.maxqty)
         Transcost! = Transcost! + wastageCost! + wastagePremiums!
      End If
   
   If multiplier > 1 Or Transcost! <= m_sglLowMarkUpLevel Then
         Transcost! = Transcost! * m_sglMarkUpLow
      ElseIf Transcost! > m_sglHighMarkUpLevel Then
         Transcost! = Transcost! * m_sglMarkUpHigh
      Else
         Transcost! = Transcost! + m_sglMarkUpMid
      End If

   
   Transcost! = Transcost! + compositeFee!
   Transcost! = Transcost! + dangerousdrugfee!
   Transcost! = Transcost! + containerPrice!
   Transcost! = Transcost! + WaterFee!
         
   Transcost! = Transcost! + allowableFee! + additionalFee!

End Sub
Sub CalculateContributions(PatientCost!, BrandPremiums$, debugMarkup$, fullPackQty!, Contributionwastagepremiums!, multiplier%)
'31Jan03 TH (PBSv4) Written and merged
'31Jan03 TH (PBSv4) Added new markup differentiation for HSD items - modular level vars should have been set already through PBSItemBillCalcs
'   "       So never call this without ensuring these vars are set correctly first !
'31Jan03 TH (PBSv4) MERGED
Dim contributions!

   If m_PBSProduct.PriceToPharmacy > 0 Then
         contributions! = m_PBSProduct.PriceToPharmacy - m_PBSProduct.CommonWealthPrice
         contributions! = (contributions! * fullPackQty) + Contributionwastagepremiums!   'amount (ie Brand Premium)
         If multiplier > 1 Or PatientCost! <= m_sglLowMarkUpLevel Then
               contributions! = contributions! * m_sglMarkUpLow
               debugMarkup$ = Format$(m_sglMarkUpLow * 100 - 100) & "%"
            ElseIf PatientCost! > m_sglHighMarkUpLevel Then
               contributions! = contributions! * m_sglMarkUpHigh
               debugMarkup$ = Format$(m_sglMarkUpHigh * 100 - 100) & "%"
            Else
               contributions! = contributions! + m_sglMarkUpMid
               debugMarkup$ = "$" & Format$(m_sglMarkUpMid)
            End If
                                                                                               
         PatientCost! = PatientCost! + contributions!
         BrandPremiums$ = Format$((contributions! - 0.001))
      End If

End Sub
Sub CalcTherapueticPremiums(PatientCost!, TherapueticPremiums$, debugMarkup$, fullPackQty!, Contributionwastagepremiums!, multiplier%)
'31Jan03 TH (PBSv4) Written and merged
'31Jan03 TH (PBSv4) Added new markup differentiation for HSD items - modular level vars should have been set already through PBSItemBillCalcs
'   "       So never call this without ensuring these vars are set correctly first !
'31Jan03 TH (PBSv4) MERGED

Dim contributions!

   If m_PBSProduct.TherapeuticGroupPrice > 0 Then
         contributions! = m_PBSProduct.TherapeuticGroupPrice - m_PBSProduct.CommonWealthPrice
         contributions! = (contributions! * fullPackQty) + Contributionwastagepremiums!   ' amount (ie Brand Premium)
         If multiplier > 1 Or PatientCost! <= m_sglLowMarkUpLevel Then
               contributions! = contributions! * m_sglMarkUpLow
               debugMarkup$ = Format$(m_sglMarkUpLow * 100 - 100) & "%"
            ElseIf PatientCost! > m_sglHighMarkUpLevel Then
               contributions! = contributions! * m_sglMarkUpHigh
               debugMarkup$ = Format$(m_sglMarkUpHigh * 100 - 100) & "%"
            Else
               contributions! = contributions! + m_sglMarkUpMid
               debugMarkup$ = "$" & Format$(m_sglMarkUpMid)
            End If
                                                                                                
         PatientCost! = PatientCost! + contributions!
         TherapueticPremiums$ = Format$((contributions! - 0.001))
      End If

End Sub
Private Sub PBSdebug(brandpremium$, escd%)
'16Nov99 SF added
'08Mar03 TH/ATW Privatised
'27Mar03 TH (PBSv4) Added mod to automatically record as exceptional price for Private issues
'01Apr03 TH (PBSv4) Added major new section for new X type Dispensing action
Dim msg$, ans$ ', sql$  '08Mar03 TH/ATW Removed

   debugPBScode$ = ""
   debugManuCode$ = ""
   debugPatientCost$ = ""
   debugSafetyNet$ = ""

   If m_sglExceptionalPrice <> 0 Then PatientCost! = m_sglExceptionalPrice   '31Jan02 TH %PBS% Added

   If (Trim$(UCase$(Billitems$(53))) = "X") Then                               '01Apr03 TH (PBSv4) Added new section for new X type
      frmPBSdebug.Caption = "Non-Schedule Allowed Benefit"                     '   "
      frmPBSdebug.Height = 1600                                                '   "
      frmPBSdebug.lblCostToPatient.top = 180                                   '   "
      frmPBSdebug.txtCostToPatient.top = 180                                   '   "
      frmPBSdebug.cmdOK.top = 715                                              '   "
      frmPBSdebug.CmdCancel.top = 715                                          '   "
      frmPBSdebug.lblManufacturersCode.Visible = False                         '   "
      frmPBSdebug.txtManufacturersCode.Visible = False                         '   "
      frmPBSdebug.lblPBScode.Visible = False                                   '   "
      frmPBSdebug.txtPBScode.Visible = False                                   '   "
      frmPBSdebug.lblSafetyNetAmount.Visible = False                           '   "
      frmPBSdebug.txtAmountToSafetyNet.Visible = False                         '   "
      frmPBSdebug.LblBrandPremium.Visible = False                              '   "
      frmPBSdebug.lblCostToPatient.Caption = "Calculated Cost        $"        '   "
      frmPBSdebug.TxtBrandPremium.Visible = False                              '   "
      frmPBSdebug.cmdEdit.Visible = False                                      '   "
      frmPBSdebug.txtCostToPatient.Text = "0.00"                               '   "
      frmPBSdebug.Show 1                                                       '   "
      If frmPBSdebug.CmdCancel.Tag = "-1" Then                                 '   "
         Unload frmPBSdebug                                                    '   "
         escd% = True                                                          '   "
      Else                                                                     '   "
         debugPatientCost$ = Trim$(frmPBSdebug.txtCostToPatient.Text)          '   "
         ExceptionalPricing True, Val(frmPBSdebug.txtCostToPatient.Text)       '   "
         'RecordExceptionalPrice                                                '   "
         popmessagecr "TO DO", "RecordExceptionalPrice"
      End If                                                                   '   "
      Unload frmPBSdebug                                                       '   "
   Else                                                                        '   "
      'If PBSitemType$ = "P" And truefalse(txtd(patdatapath$ & BillIniFile$, "PBS", "N", "ShowDebugScreen", 0)) Then                      '16Nov00 SF replaced
      'If (PBSitemType$ = "P") And (truefalse(txtd(dispdata$ & BillIniFile$, "PBS", "N", "ShowDebugScreen", 0))) And (Not EPitem) Then  '16Nov00 SF
      If ((PBSItemType$ = "P") And Trim$(UCase$(Billitems$(53))) <> "N") And (TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "ShowDebugScreen", 0))) And (Not EPItem) Then '31Jan03 TH (PBSv4) Added check on ques element for privates
      'If ((PBSItemType$ = "P") And Trim$(UCase$(Billitems$(53))) <> "N") And (TrueFalse(TxTd(dispdata$ & BillIniFile$, "PBS", "N", "ShowDebugScreen", 0))) And (Not EPItem) And (Trim$(UCase$(Billitems$(92))) <> "Y") Then  '31Mar03 TH (PBSv4) Added check on Exceptional (treat like private) '01Apr03 TH Reinstated above
            ' give the user the option to overwrite the important stuff
            '16Nov00 SF added to reset the form in case the previous dispensing was private
            frmPBSdebug.Caption = "PBS Dispense"
            frmPBSdebug.LblWarning.Visible = True
         'FrmPBSdebug.Height = 4410                 '31Jan03 TH (PBSv4) Replaced with below
         'frmPBSdebug.lblCostToPatient.Top = 1035   '   "
         'frmPBSdebug.txtCostToPatient.Top = 1035   '   "
         frmPBSdebug.lblCostToPatient.top = 1560    '   "
         frmPBSdebug.txtCostToPatient.top = 1560    '   "
         frmPBSdebug.Height = 4920                  '   "
         frmPBSdebug.cmdOK.top = 4080               '    "
         frmPBSdebug.CmdCancel.top = 4080    '31Jan03 TH (PBSv4) Added
            frmPBSdebug.lblManufacturersCode.Visible = True
            frmPBSdebug.txtManufacturersCode.Visible = True
            frmPBSdebug.lblPBScode.Visible = True
            frmPBSdebug.txtPBScode.Visible = True
            frmPBSdebug.lblSafetyNetAmount.Visible = True
            frmPBSdebug.txtAmountToSafetyNet.Visible = True
            '16Nov00 SF -----
   
         frmPBSdebug.LblBrandPremium.Visible = True   '31Jan03 TH (PBSv4)
         frmPBSdebug.TxtBrandPremium.Visible = True   '   "
         frmPBSdebug.TxtBrandPremium.Enabled = False  '   "
            
            If solventPBScode$ = "" Then
                  'frmPBSdebug.txtPBScode.Text = Trim$(getfield(snpDrug!PBScode))                  '16Nov00 SF replaced
                  frmPBSdebug.txtPBScode.Text = PBScode$                                           '16Nov00 SF
               Else
                  frmPBSdebug.txtPBScode.Text = solventPBScode$
               End If
            'frmPBSdebug.txtManufacturersCode.Text = Trim$(getfield(snpDrug!ManufacturersCode))    '16Nov00 SF replaced
            frmPBSdebug.txtManufacturersCode.Text = manuCode$                                      '16Nov00 SF
            msg$ = Format$(dp!(PatientCost!))                   '24Mar03 TH Altered (PBSv4)  '27Mar03 TH Replaced
            'msg$ = Format$(dp!(PatientCost!) + .005)     '   "                               '    "
            poundsandpence msg$, False
            frmPBSdebug.txtCostToPatient.Text = Trim$(msg$)
            
            msg$ = Format$(dp!(SafetyNetValue!))
            poundsandpence msg$, False
            frmPBSdebug.txtAmountToSafetyNet.Text = Trim$(msg$)
         
         '31Jan03 TH (PBSv4) Added Section
         msg$ = "0.00"
         msg$ = Format$(dp!(Val(brandpremium$)))       '24Mar03 TH Added (PBSv4)   '27Mar03 TH Replaced
         'msg$ = Format$(dp!(Val(brandpremium$) + .005)) '   "                     '    "
         poundsandpence msg$, False                        '    "
         frmPBSdebug.TxtBrandPremium.Text = Trim$(msg$)
         '--------------------------
         frmPBSdebug.Show 1
         If frmPBSdebug.CmdCancel.Tag = "-1" Then             '31Jan03 TH (PBSv4) Added cancel option
            Unload frmPBSdebug                             '   "
            escd% = True                                   '   "
         Else                                              '   "
            msg$ = ""
            'If Trim$(UCase$(frmPBSdebug.txtPBScode.Text)) <> Trim$(getfield(snpDrug!PBScode)) Then   '16Nov00 SF replaced
            If Trim$(UCase$(frmPBSdebug.txtPBScode.Text)) <> PBScode$ Then                            '16Nov00 SF
                  debugPBScode$ = UCase$(Trim$(frmPBSdebug.txtPBScode.Text))
                  'msg$ = msg$ & "PBS Code changed from: " & Trim$(getfield(snpDrug!PBScode)) & " to: " & debugPBScode$ & " " '16Nov00 SF replaced
                  msg$ = msg$ & "PBS Code changed from: " & PBScode$ & " to: " & debugPBScode$ & " "                          '16Nov00 SF
               End If
            'If Trim$(UCase$(frmPBSdebug.txtManufacturersCode.Text)) <> Trim$(getfield(snpDrug!ManufacturersCode)) Then    '16Nov00 SF replaced
            If Trim$(UCase$(frmPBSdebug.txtManufacturersCode.Text)) <> manuCode$ Then                                      '16Nov00 SF
                  debugManuCode$ = UCase$(Trim$(frmPBSdebug.txtPBScode.Text))
                  'msg$ = msg$ & "Manufacturers Code changed from: " & Trim$(getfield(snpDrug!ManufacturersCode)) & " to: " & debugManuCode$ & " "    '16Nov00 SF replaced
                  msg$ = msg$ & "Manufacturers Code changed from: " & manuCode$ & " to: " & debugManuCode$ & " "                                      '16Nov00 SF
               End If
            'If Val(FrmPBSdebug.txtCostToPatient.Text) <> Val(Format$(dp!(PatientCost!))) Then
            If Val(frmPBSdebug.txtCostToPatient.Text) <> Val(Format$(Val(CStr(PatientCost!)), "###.00")) Then         '24Mar03 TH Added  '27Mar03 TH Replaced
            'If Val(frmPBSdebug.txtCostToPatient.Text) <> Val(Format$(Val(CStr(PatientCost! + .005)), "###.00")) Then   '   "            '     "
                  debugPatientCost$ = Trim$(frmPBSdebug.txtCostToPatient.Text)
                  msg$ = msg$ & "Patient Cost changed from: " & Format$(dp!(PatientCost!)) & " to: " & debugPatientCost$ & " "
                  If Billitems$(53) <> "N" Then     '27Mar03 TH (PBSv4) Added to automatically record as exceptional price for Private issues
                     popmsg "#Patient Billing", "Is this dispensing to be costed as Exceptional Pricing ?", MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, ans$, escd  '31Jan02 TH %PBS% Added
                  Else                              '    "
                     ans$ = "Y"                     '    "
                  End If                            '    "
                  If ans$ = "Y" Then                                                                                                                                           '  "
                     ExceptionalPricing True, Val(frmPBSdebug.txtCostToPatient.Text)      '31Jan03 TH (PBSv4) Added
                     popmessagecr "TO DO", "RecordExceptionalPrice"
                     'RecordExceptionalPrice                                               '    "
                  Else                                                                    '    "
                     ExceptionalPricing True, 0                                           '    "
                  End If                                                                  '    "
               End If
            If Val(frmPBSdebug.txtAmountToSafetyNet.Text) <> Val(Format$(dp!(SafetyNetValue!))) Then
                  debugSafetyNet$ = Trim$(frmPBSdebug.txtAmountToSafetyNet.Text)
                  msg$ = msg$ & "SafetyNet Value changed from: " & Format$(dp!(SafetyNetValue!)) & " to: " & debugSafetyNet$
               End If
            
            Unload frmPBSdebug
            If msg$ <> "" Then
                   msg$ = "PBSDebug: RX# " & Format$(L.prescriptionid) & "/" & Format$(L.batchnumber) & ": " & msg$
                   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, msg$
               End If
         End If                                            '31Jan03 TH (PBSv4)
         '16Nov00 SF added for private dispensing
      ElseIf ((PBSItemType$ = "N") Or Trim$(UCase$(Billitems$(53))) = "N") And (Not EPItem) Then   '31Jan03 TH (PBSv4) Added Check on billitems$
         frmPBSdebug.Caption = "Private Dispense"
         frmPBSdebug.Height = 1600
         frmPBSdebug.lblCostToPatient.top = 180
         frmPBSdebug.txtCostToPatient.top = 180
         frmPBSdebug.cmdOK.top = 715
         frmPBSdebug.CmdCancel.top = 715    '30Aug01 TH %PBS% Added
         frmPBSdebug.lblManufacturersCode.Visible = False
         frmPBSdebug.txtManufacturersCode.Visible = False
         frmPBSdebug.lblPBScode.Visible = False
         frmPBSdebug.txtPBScode.Visible = False
         frmPBSdebug.lblSafetyNetAmount.Visible = False
         frmPBSdebug.txtAmountToSafetyNet.Visible = False
   
         frmPBSdebug.LblBrandPremium.Visible = False  '11Jul01 TH %PBS%
         frmPBSdebug.TxtBrandPremium.Visible = False  '   "
   
         frmPBSdebug.cmdEdit.Visible = False    '16Aug01 TH %PBS%
         msg$ = Format$(dp!(PatientCost!))
         poundsandpence msg$, False
         frmPBSdebug.txtCostToPatient.Text = Trim$(msg$)
         
         frmPBSdebug.Show 1
         
         If frmPBSdebug.CmdCancel.Tag = "-1" Then       '31Jan03 TH (PBSv4) Added cancel option
            Unload frmPBSdebug                          '   "
            escd% = True                                '   "
         Else                                           '   "
            msg$ = ""
            'If Val(FrmPBSdebug.txtCostToPatient.Text) <> Val(Format$(dp!(PatientCost!))) Then
            If Val(frmPBSdebug.txtCostToPatient.Text) <> Val(Format$(PatientCost!, "###.00")) Then '31Jan03 TH (PBSv4) Added to round OFF extraneous digits.
            debugPatientCost$ = Trim$(frmPBSdebug.txtCostToPatient.Text)
            '27Mar03 TH (PBSv4) Removed query on Exceptional pricing - now automatic for private issues.
            ''msg$ = msg$ & "Patient Cost changed from: " & Format$(dp!(PatientCost!)) & " to: " & debugPatientCost$ & " "
            ''popmsg "#Patient Billing", "Is this dispensing to be costed as Exceptional Pricing ?", MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, ans$, escd  '31Jan02 TH %PBS% Added
            ''If ans$ = "Y" Then                                                                                                                                           '   "
               ExceptionalPricing True, Val(frmPBSdebug.txtCostToPatient.Text)      '31Jan03 TH (PBSv4) Added
               popmessagecr "TO DO", "RecordExceptionalPrice"
               'RecordExceptionalPrice                                               '   "
            ''Else                                                                    '   "    Reset amt
            ''   ExceptionalPricing True, 0                                           '   "
            ''End If                                                                  '   "
         End If
   
            Unload frmPBSdebug
            If msg$ <> "" Then
                   msg$ = "PBSDebug: RX# " & Format$(L.prescriptionid) & "/" & Format$(L.batchnumber) & ": " & msg$
                   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, msg$
               End If
            End If                                            '   "
         ElseIf EPItem Then
            frmPBSdebug.Caption = "EP Item Dispense"
            frmPBSdebug.lblManufacturersCode.Visible = False
            frmPBSdebug.txtManufacturersCode.Visible = False
            frmPBSdebug.LblWarning.Visible = False
            frmPBSdebug.txtPBScode.Text = PBScode$
            msg$ = Format$(dp!(PatientCost!))
            poundsandpence msg$, False
            frmPBSdebug.txtCostToPatient.Text = Trim$(msg$)
            
            msg$ = Format$(dp!(SafetyNetValue!))
            poundsandpence msg$, False
            frmPBSdebug.txtAmountToSafetyNet.Text = Trim$(msg$)
   
            frmPBSdebug.LblBrandPremium.Visible = False  '31Jan03 TH (PBSv4)
            frmPBSdebug.TxtBrandPremium.Visible = False  '   "
   
            frmPBSdebug.cmdEdit.Visible = False    '31Jan03 TH (PBSv4)
            frmPBSdebug.Show 1
            If frmPBSdebug.CmdCancel.Tag = "-1" Then             '31Jan03 TH (PBSv4) Added cancel option
               Unload frmPBSdebug                             '   "
               escd% = True                                   '   "
            Else                                              '   "
               msg$ = ""
               If Trim$(UCase$(frmPBSdebug.txtPBScode.Text)) <> PBScode$ Then
                  debugPBScode$ = UCase$(Trim$(frmPBSdebug.txtPBScode.Text))
                  msg$ = msg$ & "PBS Code changed from: " & PBScode$ & " to: " & debugPBScode$ & " "
               End If
               If Val(frmPBSdebug.txtCostToPatient.Text) <> Val(Format$(dp!(PatientCost!))) Then
                  debugPatientCost$ = Trim$(frmPBSdebug.txtCostToPatient.Text)
                  msg$ = msg$ & "Patient Cost changed from: " & Format$(dp!(PatientCost!)) & " to: " & debugPatientCost$ & " "
                  popmsg "#Patient Billing", "Is this dispensing to be costed as Exceptional Pricing ?", MB_YESNOCANCEL + MB_ICONQUESTION + MB_DEFBUTTON3, ans$, escd  '31Jan02 TH %PBS% Added
                  If ans$ = "Y" Then                                                                                                                                           '   "
                     ExceptionalPricing True, Val(frmPBSdebug.txtCostToPatient.Text)      '31Jan03 TH (PBSv4) Added
                     popmessagecr "TO DO", "RecordExceptionalPrice"
                     'RecordExceptionalPrice                                               '   "
                  Else                                                                    '   " Clear amt.
                     ExceptionalPricing True, 0
                  End If
               End If
               If Val(frmPBSdebug.txtAmountToSafetyNet.Text) <> Val(Format$(dp!(SafetyNetValue!))) Then
                  debugSafetyNet$ = Trim$(frmPBSdebug.txtAmountToSafetyNet.Text)
                  msg$ = msg$ & "SafetyNet Value changed from: " & Format$(dp!(SafetyNetValue!)) & " to: " & debugSafetyNet$
               End If
               
               Unload frmPBSdebug
               If msg$ <> "" Then
                     msg$ = "PBSDebug: RX# " & Format$(L.prescriptionid) & "/" & Format$(L.batchnumber) & ": " & msg$
                     WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, msg$
               End If
            End If
         '16Nov00 SF -----                                      '31Jan03 TH (PBSv4)
         End If
   End If


End Sub
Sub PBSAlterBrandPremium()
'31Jan03 TH (PBSv4)  Written to allow changes to Brand Premium at Point of accepting costs on PBS Issue
'31Jan03 TH (PBSv4) MERGED
Dim ans$, valid%

   ans$ = ""
   k.nums = True
   inputwin "Patient Billing", "Enter authority number to edit the Brand Premium Cost", ans$, k
   If Not k.escd Then
      If Trim$(ans$) <> "" Then
            ValidateCardNumber ans$, "EBP", valid
            If valid Then
                  ' special authority granted
                  frmPBSdebug.TxtBrandPremium.Enabled = True
               Else
                  popmessagecr "#Patient Billing", "Invalid Authority Number"
               End If
         End If
   End If


End Sub
Sub PBSPreIssueChecks(blnPassed As Integer)
'31Jan03 TH (PBSv4) Written as convenient wrapper for all PBS checks prior to launching an issue
'31Jan03 TH (PBSv4) MERGED
'07Apr03 TH (PBSv4) If Return then dont check repeats
'24Jun03 TH Suppress if checking later !

Dim blnEscd As Boolean
   If blnPassed = 3 Then               '07Apr03 TH (PBSv4) If Return then dont check repeats
      blnPassed = True                 '   "
   Else                                '   "
      blnPassed = PBSCheckRepeats()
   End If                              '   "
   If blnPassed And (Not (TrueFalse(TxtD$(dispdata & "\" & "patmed.ini", "PatientBilling", "N", "PBSLaunchIssueScreen", 0)))) Then blnPassed = AllFieldsCorrect(0)   '18Mar03 TH (PBSv4) Added parmater   '24Jun03 TH Suppress if checking later !
   If blnPassed Then PBSCheckAuthority blnEscd
   If blnEscd Then blnPassed = False

End Sub

Function BillingInterface(ByVal SessionID As Long, ByVal strMethod As String, ByVal strParams As String, ByVal DataID As Long) As String
'03May07 TH Written as nice wrapper for the billing component
Dim HttpRequest As WinHttpRequest
Dim strPost As String
Dim strXML As String


'm_strBillingComponentURL = "http://localhost/PBST/default.aspx"

strXML = ""
strPost = "txtMethod=" & strMethod & "&txtSessionID=" & Format$(SessionID) & "&txtEntityID=" & Format(DataID) & "&txtDataID=" & Format(DataID) & "&txtDATA=" & strParams & "&txtSiteID=" & Format(gDispSite)

   Set HttpRequest = New WinHttpRequest
   HttpRequest.Open "POST", m_strBillingComponentURL, False
   HttpRequest.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
   HttpRequest.send (strPost)
   strXML = HttpRequest.responseText
   Set HttpRequest = Nothing
   strXML = "<xml>" & strXML & "</xml>"

BillingInterface = strXML

End Function

Public Function PBSCostOfItem(ByVal SessionID As Long, _
                           ByVal PBSProductID As Long, _
                           ByVal blnEPItem As Boolean, _
                           ByVal blnPrivate As Boolean, _
                           ByVal strPackSize As String, _
                           ByVal intQty As Integer, _
                           ByVal SiteID As Long, _
                           ByVal strTradeName As String, _
                           ByVal strIssueUnits As String, _
                           ByVal strDescription As String, _
                           ByVal strCost As String) As String

'----------------------------------------------------------------------------------
'
' 23Aug06 TH Written
' Used to return a text string used as output for user message
'----------------------------------------------------------------------------------
'
 'Objects
''Dim objTransport As TRNRTL10.Transport

'General
Dim strParameters As String
Dim strProductXML As String
Dim strPaymentFeesXML As String
Dim strOutput As String
Dim xmlProductdoc As MSXML2.DOMDocument
Dim xmlFeesDoc As MSXML2.DOMDocument
Dim xmlFeesNode As MSXML2.IXMLDOMNode
Dim xmlProductNode As MSXML2.IXMLDOMNode
Dim xmlNSVCodeNode As MSXML2.IXMLDOMNode
Dim strNSVCode As String
Dim strItem As String
Dim cost As Single
Dim Out As String
Dim premium As String
Dim premiumDisplay As String
Dim locPBSProduct As PBSProduct

Const TB  As String = Constants.vbTab
Const cr  As String = Constants.vbCr


'Error Handling
Const SUB_NAME = "CostOfItem"

   On Error GoTo ErrorHandler
   
   strProductXML = BillingInterface(SessionID, "GetPBSProductbyIDandSiteID", "", PBSProductID)
   
   Set xmlProductdoc = New MSXML2.DOMDocument
   If xmlProductdoc.loadXML(strProductXML) Then
      Set xmlProductNode = xmlProductdoc.selectSingleNode("xml/PBSProduct")
      CastXMLToPBSProduct xmlProductNode, locPBSProduct
      strNSVCode = Trim$(xmlProductNode.Attributes.getNamedItem("NSVCode").Text)
            
      strOutput = "................................" & TB & ".............." & TB & "............" & Chr$(0)
      If (Not blnPrivate) Then
         strItem = Trim$(locPBSProduct.maxqty) & " " & Trim$(locPBSProduct.GenericName) & " " & Trim$(locPBSProduct.FormAndStrength) & " (" & Trim$(locPBSProduct.BrandName) & ")"
         strOutput = strOutput & "Costing for:" & TB & strItem & cr & cr & cr
         strOutput = strOutput & "Trade Name : " & TB & Trim$(strTradeName) & cr
         strOutput = strOutput & "Generic Name : " & TB & Trim$(locPBSProduct.GenericName) & cr
         strOutput = strOutput & "Form and Strength : " & TB & Trim$(locPBSProduct.FormAndStrength) & cr
         strOutput = strOutput & "ROP : " & TB & Trim$(locPBSProduct.ROP) & cr & cr
         strOutput = strOutput & "PBS Code : " & TB & Trim$(locPBSProduct.PBScode) & cr
         strOutput = strOutput & "Manufacturers Code : " & TB & Trim$(locPBSProduct.ManufacturersCode) & cr
         strOutput = strOutput & "NSV Code : " & TB & strNSVCode & cr & cr
         strOutput = strOutput & "Restriction Flag : " & TB & Trim$(locPBSProduct.RestrictionFlag) & cr
         strOutput = strOutput & "Drug Type Code : " & TB & Trim$(locPBSProduct.DrugTypeCode) & cr
         strOutput = strOutput & "Require Solvent : " & TB & Trim$(locPBSProduct.SolventRequired) & cr & cr
         strOutput = strOutput & "Max Qty : " & TB & Trim$(locPBSProduct.maxqty) & cr
         strOutput = strOutput & "Max Repeats : " & TB & Trim$(locPBSProduct.MaxRepeats) & cr & cr
      
         '---------------------------------------------------------------
      
         ' general patient
         strOutput = strOutput & "General Patient Cost : "
         cost = (CSng(locPBSProduct.MaxRecordableValue) * intQty)
         If cost > (CSng(m_PatFees.GeneralPatient) * intQty) Then cost = (CSng(m_PatFees.GeneralPatient) * intQty)
         Out$ = Format$(cost)
         poundsandpence Out$, False
         strOutput = strOutput & TB & "$ " & Trim$(Out$) & cr & cr
         
         ' concession patient
         strOutput = strOutput & "Concessional Patient Cost : "
         Out$ = Format$(CSng(m_PatFees.ConcessionPatient) * intQty)
         poundsandpence Out$, False
         strOutput = strOutput & TB & "$ " & Trim$(Out$) & cr & cr
            
         ' repatriation patient
         strOutput = strOutput & "Repatriation Patient Cost : "
         'out$ = Format$(GetField(snap!ConcessionPatient) * intQty)
         'poundsandpence out$, False
         strOutput = strOutput & TB & "$ " & Trim$(Out$) & cr & cr
         
         ' private dispense
         'strOutput = strOutput & "Private Patient Cost : "
         'Cost! = getfield(snpDrug!MaxRecordableValue)
         'out$ = (Cost! * getfield(snap!privatemarkup)) + getfield(snap!privatedispensingfee)
         'poundsandpence out$, False
         'strOutput = strOutput & tb & tb & tb & money(5) & Trim$(out$) & cr & cr
         '-----------------------------
            
         premium$ = Format$(CSng(locPBSProduct.brandpremium) * intQty)
         poundsandpence premium$, False
         premiumDisplay$ = "$ " & Trim$(premium$)
         strOutput = strOutput & "Brand Premium : " & TB & premiumDisplay$ & cr
         premium$ = Format$(CSng(locPBSProduct.TherapeuticPremium) * intQty)
         poundsandpence premium$, False
         premiumDisplay$ = "$ " & Trim$(premium$)
         strOutput = strOutput & "Therapeutic Premium : " & TB & premiumDisplay$ & cr
         Out$ = Format$(CSng(locPBSProduct.MaxRecordableValue) * intQty)
         poundsandpence Out$, False
      
         strOutput = strOutput & "Max Safety Net : " & TB & "$ " & Trim$(Out$) & cr & cr & cr
         If Trim$(m_PBSProduct.RestrictionFlag) <> "" Then strOutput = strOutput & "Restrictions apply for use"
            
            '--------------------------------------------------
         ElseIf blnPrivate Then
            If (Not blnEPItem) Then 'And (foundDrugitem)
               strItem = Trim$(locPBSProduct.maxqty) & " " & Trim$(locPBSProduct.GenericName) & " " & Trim$(locPBSProduct.FormAndStrength) & " (" & Trim$(locPBSProduct.BrandName) & ")"
               strOutput = strOutput & "Costing for:" & TB & strItem & cr & cr & cr
               strOutput = strOutput & "Trade Name : " & TB & Trim$(strTradeName) & cr
               strOutput = strOutput & "Generic Name : " & TB & Trim$(locPBSProduct.GenericName) & cr
               strOutput = strOutput & "Form and Strength : " & TB & Trim$(locPBSProduct.FormAndStrength) & cr
               strOutput = strOutput & "ROP : " & TB & Trim$(locPBSProduct.ROP) & cr & cr
               strOutput = strOutput & "PBS Code : " & TB & Trim$(locPBSProduct.PBScode) & cr
               strOutput = strOutput & "Manufacturers Code : " & TB & Trim$(locPBSProduct.ManufacturersCode) & cr
               strOutput = strOutput & "NSV Code : " & TB & strNSVCode & cr & cr
               strOutput = strOutput & "Restriction Flag : " & TB & Trim$(locPBSProduct.RestrictionFlag) & cr
               strOutput = strOutput & "Drug Type Code : " & TB & Trim$(locPBSProduct.DrugTypeCode) & cr
               strOutput = strOutput & "Require Solvent : " & TB & Trim$(locPBSProduct.SolventRequired) & cr & cr
               strOutput = strOutput & "Max Qty : " & TB & Trim$(locPBSProduct.maxqty) & cr
               strOutput = strOutput & "Max Repeats : " & TB & Trim$(locPBSProduct.MaxRepeats) & cr & cr
            Else
               strItem = strDescription
               'plingparse strItem, "!"
               replace strDescription, "!", " ", 0
               strOutput = strOutput & "Costing for:" & TB & strItem & cr & cr & cr
               strOutput = strOutput & "Trade Name : " & TB & Trim$(strTradeName) & cr
            End If
            strOutput = strOutput & cr & cr & "Qty : "
            strOutput = strOutput & TB & Format$(intQty) & " " & Trim$(strIssueUnits) & cr & cr
   
            'Allow DispensedPriceMaxQty to be used or d.cost
            If (Not blnEPItem) Then  'And (foundDrugitem)
               If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "Y", "UseDispensedPriceMaxQty", 0)) Then
                  cost = (Val(locPBSProduct.CommonWealthDispensed) / Val(strPackSize)) * intQty
               Else
                  cost = ((Val(strCost) / Val(strPackSize)) / 100) * intQty
               End If
            Else
               cost = ((Val(strCost) / Val(strPackSize)) / 100) * intQty
            End If
            cost = (cost * CSng(m_PatFees.PrivateMarkup)) + CSng(m_PatFees.PrivateDispensingFee)
            
            Out$ = Format$(cost!)
            poundsandpence Out$, False
            strOutput = strOutput & cr & cr & "Private Patient Cost : "
            strOutput = strOutput & TB & "$ " & Trim$(Out$) & cr & cr
            '-----------------------------
         End If
      'Set xmlFeesNode = Nothing
      Set xmlProductNode = Nothing
      'End If
      'Set xmlFeesDoc = Nothing
   End If
   Set xmlProductdoc = Nothing

ExitPoint:

   PBSCostOfItem = strOutput
   
      
   On Error GoTo 0
   '''BubbleOnError ErrorState
   Exit Function
       
'-------------------------------Error Handling Block----------------------------------------
ErrorHandler:

   '''CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint
End Function
Sub SetUpBilling(ByVal lngPrescriptionID As Long, ByVal lngPatientID As Long)
'08May07 TH Written .
'Should be called by any application using billing methodology
'Called from refresh state (ie whenever the ocx is being prodded.
'Here we check the "big switch" and set up the billing component that we are going to use.
'returns true if billing is set up
Dim intNumBillingItems As Integer
Dim blnOK As Boolean

   m_blnPBSDispenseOn = True 'This is on until we switch it off
   
   If m_blnBillingInitialised Then
      If isPBS() Then
      'get any repeat info
      PBSGetDrugRepeat lngPrescriptionID
      GetCurrentPrescriberDetails
      ''MsgBox "PatientID = " & Format(lngPatientID) 'PBSDEBUG
      blnOK = PBSGetPatient(lngPatientID)
      If Not blnOK Then
         'We have no patient we should flag this and turn off billing
         m_blnPBSDispenseOn = False
         'm_blnBillingInitialised = False
         MsgBox "PatientLoad has failed" 'PBSDEBUG
         'Message
      Else
         '
         'put whatever other start up validation is required here
         '
         blnAddToPRF = True '10May always add to the safety net by default
          
      End If
      Else
         'Other Types Here
      End If
   End If
 
   
End Sub
Sub PBSGetDrugRepeat(ByVal lngPrescriptionID As Long)
Dim strXML As String
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMNode
'Dim blnResult As Boolean

   'blnResult = False
   'TH 99PBS Set objBilling = CreateObject(m_strBillingComponentURL)
   'strXML = objBilling.PBSPaymentFees(g_SessionID)
   'Set objBilling = Nothing
   'lngEntityID = 7
   
   m_PBSDrugRepeat.PBSDrugRepeatID = -1 'Use this as flag that we have no repeat record
   m_PBSDrugRepeat.NumberOfRepeats = -1

   strXML = BillingInterface(g_SessionID, "GetPBSDrugRepeatbyRequestID", "", lngPrescriptionID)
   If InStr(LCase(strXML), "pbsdrugrepeat") > 0 Then 'And (Not m_blnPBSNewScript
      Set xmlDoc = New MSXML2.DOMDocument
      If xmlDoc.loadXML(strXML) Then
         'm_PatFees.AdditionalFeeEP =
         Set xmlnode = xmlDoc.selectSingleNode("xml/PBSDrugRepeat")
         On Error Resume Next
         'blankPBSPatient m_PBSPatient
         
         
         m_PBSDrugRepeat.ACCitem = xmlnode.Attributes.getNamedItem("ACCitem").Text
         m_PBSDrugRepeat.DispensQty = xmlnode.Attributes.getNamedItem("DispensQty").Text
         m_PBSDrugRepeat.ExcepDescription = xmlnode.Attributes.getNamedItem("ExcepDescription").Text
         m_PBSDrugRepeat.ExcepQty = Val(xmlnode.Attributes.getNamedItem("ExcepQty").Text)
         m_PBSDrugRepeat.ExceptionalPrice = xmlnode.Attributes.getNamedItem("ExceptionalPrice").Text
         m_PBSDrugRepeat.ItemStatus = xmlnode.Attributes.getNamedItem("ItemStatus").Text
         m_PBSDrugRepeat.ManufacturersCode = xmlnode.Attributes.getNamedItem("ManufacturersCode").Text
         m_PBSDrugRepeat.NumberOfRepeats = xmlnode.Attributes.getNamedItem("NumberOfRepeats").Text
         m_PBSDrugRepeat.OriginalApprovalNumber = xmlnode.Attributes.getNamedItem("OriginalApprovalNumber").Text
         m_PBSDrugRepeat.OriginalDate = xmlnode.Attributes.getNamedItem("OriginalDate").Text
         m_PBSDrugRepeat.OriginalLastIssuedDate = xmlnode.Attributes.getNamedItem("OriginalLastIssuedDate").Text
         m_PBSDrugRepeat.OriginalScriptNumber = xmlnode.Attributes.getNamedItem("OriginalScriptNumber").Text
         m_PBSDrugRepeat.OriginalTimesIssued = xmlnode.Attributes.getNamedItem("OriginalTimesIssued").Text
         m_PBSDrugRepeat.PatRecNo = xmlnode.Attributes.getNamedItem("PatRecNo").Text
         m_PBSDrugRepeat.PBScode = xmlnode.Attributes.getNamedItem("PBScode").Text
         m_PBSDrugRepeat.PBSDrugRepeatID = (xmlnode.Attributes.getNamedItem("PBSDrugRepeatID").Text)
         m_PBSDrugRepeat.QtyOwing = xmlnode.Attributes.getNamedItem("QtyOwing").Text
         m_PBSDrugRepeat.RepeatInterval = xmlnode.Attributes.getNamedItem("RepeatInterval").Text
         m_PBSDrugRepeat.RequestID = xmlnode.Attributes.getNamedItem("RequestID").Text
         m_PBSDrugRepeat.RxNumber = xmlnode.Attributes.getNamedItem("RxNumber").Text
         m_PBSDrugRepeat.SolventCode = xmlnode.Attributes.getNamedItem("SolventCode").Text
         m_PBSDrugRepeat.SpecialAuthorityNum = xmlnode.Attributes.getNamedItem("SpecialAuthorityNum").Text
         m_PBSDrugRepeat.Status = xmlnode.Attributes.getNamedItem("Status").Text
         m_PBSDrugRepeat.StopDate = xmlnode.Attributes.getNamedItem("StopDate").Text
         m_PBSDrugRepeat.Type = xmlnode.Attributes.getNamedItem("Type").Text
         m_PBSDrugRepeat.VariableQtys = xmlnode.Attributes.getNamedItem("VariableQtys").Text
         m_PBSDrugRepeat.NonpBS = Val(xmlnode.Attributes.getNamedItem("NonPBS").Text)
         m_PBSDrugRepeat.NumberOfIssues = Val(xmlnode.Attributes.getNamedItem("NumberOfIssues").Text)
         m_PBSDrugRepeat.DrugID = Val(xmlnode.Attributes.getNamedItem("DrugID").Text)
         On Error GoTo 0
         Set xmlnode = Nothing
      End If
      Set xmlDoc = Nothing
   Else
   'Create a New record and write it to the DB
         m_PBSDrugRepeat.ACCitem = ""
         m_PBSDrugRepeat.DispensQty = "0"
         m_PBSDrugRepeat.ExcepDescription = ""
         m_PBSDrugRepeat.ExcepQty = 0
         m_PBSDrugRepeat.ExceptionalPrice = "0"
         m_PBSDrugRepeat.ItemStatus = ""
         m_PBSDrugRepeat.ManufacturersCode = ""
         m_PBSDrugRepeat.NumberOfRepeats = "-1"
         m_PBSDrugRepeat.OriginalApprovalNumber = ""
         m_PBSDrugRepeat.OriginalDate = ""
         m_PBSDrugRepeat.OriginalLastIssuedDate = ""
         m_PBSDrugRepeat.OriginalScriptNumber = ""
         m_PBSDrugRepeat.OriginalTimesIssued = 0
         m_PBSDrugRepeat.PatRecNo = 0
         m_PBSDrugRepeat.PBScode = ""
         m_PBSDrugRepeat.PBSDrugRepeatID = 0
         m_PBSDrugRepeat.QtyOwing = 0
         m_PBSDrugRepeat.RepeatInterval = 0
         m_PBSDrugRepeat.RequestID = lngPrescriptionID
         m_PBSDrugRepeat.RxNumber = Format$(L.prescriptionid)
         m_PBSDrugRepeat.SolventCode = ""
         m_PBSDrugRepeat.SpecialAuthorityNum = ""
         m_PBSDrugRepeat.Status = ""
         m_PBSDrugRepeat.StopDate = ""
         m_PBSDrugRepeat.Type = ""
         m_PBSDrugRepeat.VariableQtys = "0"
         m_PBSDrugRepeat.NonpBS = 0
         m_PBSDrugRepeat.NumberOfIssues = 0 '03Jun07 TH Added
         m_PBSDrugRepeat.DrugID = 0
         PBSDrugRepeatWrite
   End If

   

 
End Sub
Function PBSGetPatient(ByVal lngEntityID As Long) As Boolean
Dim strXML As String
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMNode
Dim blnResult As Boolean

   blnResult = False
   
   'lngEntityID = 7        'Debug
   'BeneficiaryType = "G"  ' "
   
   strXML = BillingInterface(g_SessionID, "GetPBSPatientDetails", "", lngEntityID)
   If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PBSDebug", 0)) Then MsgBox strXML 'PBSDEBUG
   WriteLog "c:\pbs.log", 1, "PBSDEBUG", strXML 'PBSDEBUG
   If InStr(LCase(strXML), "pbspatient") > 0 Then 'And (Not m_blnPBSNewScript
      Set xmlDoc = New MSXML2.DOMDocument
      If xmlDoc.loadXML(strXML) Then
         'm_PatFees.AdditionalFeeEP =
         Set xmlnode = xmlDoc.selectSingleNode("xml/PBSPatient")
         On Error Resume Next
         blankPBSPatient m_PBSPatient
         m_PBSPatient.BeneficiaryType = xmlnode.Attributes.getNamedItem("PBSBeneficiaryType").Text
         BeneficiaryType = m_PBSPatient.BeneficiaryType
         m_PBSPatient.ConcessionExpiry = xmlnode.Attributes.getNamedItem("ConcessionExpiry").Text
         m_PBSPatient.ConcessionNumber = xmlnode.Attributes.getNamedItem("ConcessionNumber").Text
         m_PBSPatient.Familygroupnumber = Val(xmlnode.Attributes.getNamedItem("Familygroupnumber").Text)
         m_PBSPatient.MedicareExpirydate = xmlnode.Attributes.getNamedItem("MedicareExpirydate").Text
         m_PBSPatient.MedicareNumber = xmlnode.Attributes.getNamedItem("MedicareNumber").Text
         m_PBSPatient.PBSPatientID = xmlnode.Attributes.getNamedItem("PBSPatientID").Text
         m_PBSPatient.PreviousDateDispensed = xmlnode.Attributes.getNamedItem("PreviousDateDispensed").Text
         m_PBSPatient.RepatriationCardType = xmlnode.Attributes.getNamedItem("RepatriationCardType").Text
         m_PBSPatient.RepatriationNumber = xmlnode.Attributes.getNamedItem("RepatriationNumber").Text
         m_PBSPatient.SafetyNetNumber = xmlnode.Attributes.getNamedItem("SafetyNetNumber").Text
         m_PBSPatient.Scripts = Int(xmlnode.Attributes.getNamedItem("Scripts").Text)
         m_PBSPatient.Subnumerate = xmlnode.Attributes.getNamedItem("Subnumerate").Text
         m_PBSPatient.TemporaryExpiryDate = xmlnode.Attributes.getNamedItem("TemporaryExpiryDate").Text
         m_PBSPatient.TemporaryMedicareNumber = xmlnode.Attributes.getNamedItem("TemporaryMedicareNumber").Text
         m_PBSPatient.ThresholdAmount = CDbl(xmlnode.Attributes.getNamedItem("ThresholdAmount").Text)
         On Error GoTo 0
         blnResult = True
         Set xmlnode = Nothing
      End If
      Set xmlDoc = Nothing
   End If

   PBSGetPatient = blnResult

End Function
Sub blankPBSPatient(ByRef PBSPatient As PBSPatientStruct)

   PBSPatient.BeneficiaryType = "G"
   PBSPatient.ConcessionExpiry = ""
   PBSPatient.ConcessionNumber = ""
   PBSPatient.Familygroupnumber = 0
   PBSPatient.MedicareExpirydate = ""
   PBSPatient.MedicareNumber = ""
   PBSPatient.PBSPatientID = 0
   PBSPatient.PreviousDateDispensed = ""
   PBSPatient.RepatriationCardType = 0
   PBSPatient.RepatriationNumber = ""
   PBSPatient.SafetyNetNumber = ""
   PBSPatient.SafetyNetType = ""
   PBSPatient.Scripts = 0
   PBSPatient.Subnumerate = ""
   PBSPatient.TemporaryExpiryDate = ""
   PBSPatient.TemporaryMedicareNumber = ""
   PBSPatient.ThresholdAmount = 0
   
End Sub
Private Sub AddWaterCostEP(water%, EP%)
'16Nov99 SF added for PBS. Some ready prepared items need the additional of a water cost or to be charged as an EP item.
'08Mar03 TH/ATW Privatised

Dim additionalcosts$
Dim myError$, myErr%

Dim xmlDoc As MSXML2.DOMDocument
Dim strXML As String
Dim strParams As String
Dim xmlnode As MSXML2.IXMLDOMNode

   
   On Error GoTo AddWaterCostEPErr
   
   water = False
   EP = False
   
   strParams = gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, m_PBSProduct.PBScode) & _
               gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 2, m_PBSProduct.ManufacturersCode)
         
   strXML = BillingInterface(g_SessionID, "GetPBSEPWaterbyPBSCodeandManufacturersCode", strParams, 0)
   Set xmlDoc = New MSXML2.DOMDocument
   If InStr(LCase(strXML), "PBSEPWater") > 0 Then
      If xmlDoc.loadXML(strXML) Then
         Set xmlnode = xmlDoc.selectSingleNode("xml/PBSEPWater")
         additionalcosts$ = xmlnode.Attributes("AdditionalCosts").Text
         If InStr(UCase$(additionalcosts$), "W") > 0 Then water = True
         If InStr(UCase$(additionalcosts$), "EP") > 0 Then EP = True
         Set xmlnode = Nothing
      End If
   End If
   Set xmlDoc = Nothing


AddWaterCostEPExit:
   On Error Resume Next
''   snap.Close: Set snap = Nothing
   On Error GoTo 0
   Exit Sub

AddWaterCostEPErr:
   myError$ = Trim$(Error$)
   myErr = Err
   Err = 0 '14May07 TH Added
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: AddWaterCostEP) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & myError$ & cr & "Error number: " & myErr             '*16May00 SF relaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: AddWaterCostEP) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & myError$ & cr & "Error number: " & myErr   '*16May00 SF
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: AddWaterCostEP" & cr & "Error: " & myError$ & cr & "Error number: " & myErr
   Resume AddWaterCostEPExit

End Sub

Private Sub ParsePatientBill(dispensingFee!, index%, contraceptive%, printRptAuth%)
' put current label information on the heap form printing
'10Oct99 SF blanks out parts of the label not relevant to private dispensing
'16Nov00 SF added additional PBS elements
'04Mar02 TH Added record of labf into type for reprint of owing reports (#MOJ#)
'04Mar02 TH Added Parameter to Reprint call (#MOJ#)
'31Jan03 TH (PBSv4) MERGED
'                   removed replace of /tab in pbDirections
'                   Changed section to allow defaults (blank for privates) and check founddrugItem
'                   Removed pbOrigRXDate element
'                   Change handling of pbMedicarenumber to allow for temporary number to be used if present
'                   Added pbExPrice element to show exceptional price if added
'                   Added original element to display original rx details if they are present
'                   Added pbMNExpiry element to display expiry, or temp medicare expiry date if this is used
'                   Added pblastissueddate element for Unoriginal Dispensing type
'06Mar03 TH (PBSv4) Append line number (Subnumerate) to MedicareNumber element
'08Mar03 TH/ATW Privatised and removed unused variables
'18Mar03 TH (PBSv4) Reinstated pbOrigRXDate - but now use from billitems$ only
'08Apr03 TH (PBSv4) Added pbBrandName20 element which is standard element truncated (if necessary) to 20 chars
'29Jul03 TH (PBSv4) Added clause for exceptional items to ensure correct serial number is available on heap.

Dim DT1 As DateAndTime
Dim DT2 As DateAndTime
Dim success%, repeatsAllowed%, qtyOwed!
Dim chars$, repeatByDate$, txt$, cost1$, cost2$, cost3$, rxnum$
Dim X%
Dim temp$
Dim intBillingtype As Integer
      
                                        
   FillHeapDrugInfo gPRNheapID, d, 0
   FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
   Heap 10, gPRNheapID, "pbCaseNo", Trim$(pid.caseno), 0
   buildname pid, False, txt$
   Heap 10, gPRNheapID, "pbName", txt$, 0
   Heap 10, gPRNheapID, "pbsdate", Format$(Now, "ddmmyy"), success
   Heap 10, gPRNheapID, "pbAddress1", Trim$(pidExtra.Address1), success
   Heap 10, gPRNheapID, "pbAddress2", Trim$(pidExtra.Address2), success
   Heap 10, gPRNheapID, "pbsdate", Format$(Now, "ddmmyy"), success
   
   intBillingtype = Val(TxtD(dispdata$ & "\PATBILL.INI", "PatientBilling", "", "BillingType", 0))

   
   Select Case intBillingtype
      Case 1:

''            ' check if anything to owe on this dispensing
''            If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PatientBilling", "N", "PrintOwesOnLabel", 0)) Then
''                  qtyOwed! = NumberOfOwes!(0)
''                  If qtyOwed! = -1 Then qtyOwed! = 0      ' should never happen here
''               Else
''                  qtyOwed! = 0
''               End If
''
''            ' work out and display repeat expiry for dispensed item
''            repeatsAllowed% = NumberOfRepeats%()
''            If FatalErr% Then Exit Sub
''            If (1 + repeatsAllowed%) = L.batchnumber Or L.batchnumber = 0 Then
''                  txt$ = TxtD(dispdata$ & BillIniFile$, "PatientBilling", "", "LastRepeatText", 0)
''                  If qtyOwed! > 0 Then txt$ = txt$ & " but owed " & Format$(toOwe!) & Trim$(d.PrintformV)
''                  Heap 10, gPRNheapID, "pbRepeatText", txt$, success
''               Else
''                  dt1.mint = L.StopDate
''                  minstodate dt1
''                  DateToString dt1, repeatByDate$
''
''                  txt$ = TxtD(dispdata$ & BillIniFile$, "PatientBilling", "", "RepeatText", 0)
''                  txt$ = txt$ & Format$((1 + repeatsAllowed%) - L.batchnumber) & " repeat(s) before "
''                  txt$ = txt$ & repeatByDate$
''                  If qtyOwed! > 0 Then txt$ = txt$ & " and owed " & Format$(toOwe!) & Trim$(d.PrintformV)
''               End If
''            Heap 10, gPRNheapID, "pbRepeatText", txt$, success
''
''
''            ' hold for invoice label (to be printed at end of patient dispensing) and put on heap for current label
''            ReDim lines$(5)
''            deflines d.Description, lines$(), "!", 1, 0
''            GetCosts cost1$, cost2$, cost3$
''
''            If Billitems(26) = "N" Then   ' ACC
''                  ' HBL subsidised
''                  If Index% > 100 Then ReDim Preserve PharmInvBill(Index)      'just incase anybody has 100+ items in one go
''                  PharmInvBill(Index%).totalCost = Format$(Val(cost1$) + Val(cost2$) + Val(cost3$))      ' copayment + manufacturers premium + pharmac subsidy
''                  PharmInvBill(Index%).pharmacsubsidy = cost2$                                           ' pharmac subsidy
''                  PharmInvBill(Index%).copayManuPrem = Format$(Val(cost1$) + Val(cost3$))                ' copayment + manufacturers premium
''                  PharmInvBill(Index%).labeldirections = Trim$(L.drdirection)                            ' label
''                  If newDispensing% Then
''                        PharmInvBill(Index%).Qty = Format$(toDispens!) & Trim$(d.PrintformV)
''                     Else
''                        PharmInvBill(Index%).Qty = Format$(toDispens!) & Trim$(d.PrintformV) & " (Owed)"
''                     End If
''                  txt$ = Trim$(d.Description)
''                  plingparse txt$, "!"
''                  PharmInvBill(Index%).drugdescription = txt$
''                  'PharmInvBill(index%).rxno = Format$(labf&)              '16May00 SF replaced
''                  PharmInvBill(Index).rxno = Format$(L.prescriptionid)     '16May00 SF
''                  PharmInvBill(Index%).rptNumber = L.batchnumber
''                  PharmInvBill(Index%).firstPartDesc = lines$(1)      ' first part of drug description
''                  PharmInvBill(Index%).label = Labf&               '04Mar02 TH Added for reprint of owing reports (#MOJ#)
''               Else
''                  ' private insurance (ACC)
''                  Heap 10, gPRNheapID, "ACCcost", Format$(Val(cost1$) + Val(cost2$) + Val(cost3$)), success
''                  Heap 10, gPRNheapID, "ACCqty", Format$(toDispens!), success
''                  Heap 10, gPRNheapID, "ACCinvNum", Trim$(Billitems$(27)), success
''
''                  If Not fileexists(dispdata$ & "\ACCINV.RTF") Then
''                        popmessagecr "!Patient Billing", "File: " & dispdata$ & "\ACCINV.RTF" & " not found" & cr & "Cannot print an ACC invoice"
''                     Else
''                        ParseThenPrint "ACCinvoice", dispdata$ & "\ACCINV.RTF", 1, 0
''                     End If
''               End If
''
''            txt$ = money$(5) & cost1$ & " + " & money$(5) & cost3$ & " = " & money$(5) & Format$(Val(cost1$) + Val(cost3$))
''
''            Heap 10, gPRNheapID, "pbItemCost", txt$, success
''
''            ' put on heap for rest of 3-part label print "displbl.rtf" (to be printed after every dispens)
''            'rxnum$ = Format$(labf&)                  '16May00 SF replaced
''            rxnum$ = Format$(L.prescriptionid)        '16May00 SF
''            Heap 10, gPRNheapID, "pbPharmacDesc", lines$(1) & " " & lines$(2), success
''            Heap 10, gPRNheapID, "pbRXNo", Trim$(rxnum$) & "/" & Format$(L.batchnumber), success
''            Heap 10, gPRNheapID, "pbRXNoSix", Trim$(Right$(rxnum$, 6)) & "/" & Format$(L.batchnumber), success
''            Heap 10, gPRNheapID, "pb5chrD", LCase$(Left$(lines$(1), 5)), success
''            Heap 10, gPRNheapID, "pbQty", Format$(toDispens!) & Trim$(LCase$(d.PrintformV)), success
''
''            If foundDrugitem Then                              '10Oct99 SF added
''                  If (snpDrug!pharmacsubsidy * toDispens!) + dispensingFee! > copayment! Then
''                        chars$ = "SS"
''                     Else
''                        If copayment! <= 2 Then
''                                 chars$ = "XSS"
''                              Else
''                                 chars$ = ""
''                              End If
''                     End If
''                  Heap 10, gPRNheapID, "pbPay", chars$, success
''               Else                                            '10Oct99 SF added
''                  Heap 10, gPRNheapID, "pbPay", "", success    '10Oct99 SF added
''               End If                                          '10Oct99 SF added

         '16Nov99 SF added for PBS.  Parses and prints the repeat authority form
      Case 2:
         ' setup and print repeat authorisation form if not original dispesning
         '01Jun07 TH If L.batchnumber > 0 Or (L.batchnumber = 0 And PBSItemStatus$ = "R") Then
         If m_PBSDrugRepeat.NumberOfIssues > 0 Or (m_PBSDrugRepeat.NumberOfIssues = 0 And PBSItemStatus$ = "R") Then
            ' blank all claim types
            Heap 10, gPRNheapID, "pbGen", "", success
            Heap 10, gPRNheapID, "pbCon", "", success
            Heap 10, gPRNheapID, "pbEnt", "", success
            Heap 10, gPRNheapID, "pbRpbs", "", success
            'If PBSItemType$ = "P" Then
            If PBSItemType$ = "P" Or Trim$(UCase$(Billitems$(53))) = "X" Then   '29Jul03 TH Added clause for exceptional items
               Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                                          
               Select Case BeneficiaryType$
                  Case "C"
                     If safetyNetCard$ = "" Then
                        ' concessional claim
                        Heap 10, gPRNheapID, "pbCon", "Con", success
                        Heap 10, gPRNheapID, "pbEntitlementNumber", Billitems$(51), success
                        Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                     Else
                        ' entitlement claim
                        Heap 10, gPRNheapID, "pbEnt", "Ent", success
                        Heap 10, gPRNheapID, "pbEntitlementNumber", Billitems$(57), success
                        Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                     End If
                  Case "G"
                  If safetyNetCard$ = "" Then
                     ' general patient claim
                     Heap 10, gPRNheapID, "pbGen", "Gen", success
                     Heap 10, gPRNheapID, "pbEntitlementNumber", "", success
                     If safeNet Then
                        Heap 10, gPRNheapID, "pbSerialNum", "Saf-Net", success
                     Else
                        Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                     End If
                  Else
                     ' entitlement claim
                     Heap 10, gPRNheapID, "pbEnt", "Ent", success
                     Heap 10, gPRNheapID, "pbEntitlementNumber", Billitems$(57), success
                     Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                  End If
               Case "R"
                  If safetyNetCard$ = "" Then
                     ' RPBS claim
                     Heap 10, gPRNheapID, "pbRpbs", "Rep", success
                     Heap 10, gPRNheapID, "pbEntitlementNumber", Billitems$(51), success
                     Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                  Else
                     ' entitlement claim
                     Heap 10, gPRNheapID, "pbEnt", "Ent", success
                     Heap 10, gPRNheapID, "pbEntitlementNumber", Billitems$(57), success
                     Heap 10, gPRNheapID, "pbSerialNum", serialNumWithPrefix$, success
                  End If
               
            End Select
         Else
            Heap 10, gPRNheapID, "pbEntitlementNumber", "", success
            Heap 10, gPRNheapID, "pbSerialNum", "Non-PBS", success
         End If

            
         txt$ = Trim$(L.drdirection)
         replace txt$, crlf, Chr$(30), 0
         replace txt$, Chr$(10), Chr$(30), 0
         replace txt$, cr, Chr$(30), 0
         replace txt$, Chr$(30), " \par ", 0
         Heap 10, gPRNheapID, "pbDirections", txt$, success

         txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "ApprovalNumber", 0)
         Heap 10, gPRNheapID, "pbQty", Format$(Qty!), success
         Heap 10, gPRNheapID, "pbApprNum", txt$, success
         Heap 10, gPRNheapID, "pbAuthorityNumber", SpecialAuthorityNum$, success
         If Trim$(OriginalScriptNumber$) = "" Then
            '01Jun07 TH Heap 10, gPRNheapID, "pbRxNum", Format$(L.prescriptionid) & "/" & Format$(L.batchnumber), success
            Heap 10, gPRNheapID, "pbRxNum", Format$(L.prescriptionid) & "/" & Format$(m_PBSDrugRepeat.NumberOfIssues), success
            Heap 10, gPRNheapID, "pbRxNumASC", "", success
         Else
            ' entered as unoriginal
            Heap 10, gPRNheapID, "pbRxNum", Trim$(OriginalScriptNumber$), success
            '01Jun07 TH Heap 10, gPRNheapID, "pbRxNumASC", Format$(L.prescriptionid) & "/" & Format$(L.batchnumber), success
            Heap 10, gPRNheapID, "pbRxNumASC", Format$(L.prescriptionid) & "/" & Format$(m_PBSDrugRepeat.NumberOfIssues), success
         End If
            
         '31Jan03 TH (PBSv4) Changed section to allow defaults and check founddrugItem
         If foundDrugitem And Not EPItem Then  '     "
            If Trim$(m_PBSProduct.PBScode) <> "" Then                                                     '31Jan03 TH (PBSv4)
               Heap 10, gPRNheapID, "PbBrandName", Trim$(m_PBSProduct.BrandName), success              '    "
               Heap 10, gPRNheapID, "pbFormAndStrength", Trim$(m_PBSProduct.FormAndStrength), success  '    "
               Heap 10, gPRNheapID, "PbBrandName20", Trim$(Left$(m_PBSProduct.BrandName & Space$(20), 20)), success  '08Apr03 TH (PBSv4) Added
            Else
               temp$ = d.LabelDescription  ' temp$ = d.Description XN 4Jun15 98073 New local stores description
               plingparse temp$, "!"
               Heap 10, gPRNheapID, "PbBrandName", Trim$(d.tradename), success
               Heap 10, gPRNheapID, "pbFormAndStrength", Trim$(temp$), success
               Heap 10, gPRNheapID, "PbBrandName20", Trim$(Left$(d.tradename & Space$(20), 20)), success  '08Apr03 TH (PBSv4) Added
            End If
         Else                                                         '31Jan03 TH (PBSv4) Blank for Private
            Heap 10, gPRNheapID, "PbBrandName", "", success           '   "       Non PBS dispensing
            Heap 10, gPRNheapID, "pbFormAndStrength", "", success     '   "
            Heap 10, gPRNheapID, "PbBrandName20", "", success            '08Apr03 TH (PBSv4) Added
         End If                                                       '   "
         repeatsAllowed = NumberOfRepeats()
         Heap 10, gPRNheapID, "pbNumRpts", Format$(repeatsAllowed), success
         '01Jun07 TH Heap 10, gPRNheapID, "pbRptsLft", Format$(repeatsAllowed - (L.batchnumber - 1)), success
         Heap 10, gPRNheapID, "pbRptsLft", Format$(repeatsAllowed - (m_PBSDrugRepeat.NumberOfIssues - 1)), success
         
                                           
         If debugPBScode$ = "" Then
            If solventPBScode$ = "" Then
               Heap 10, gPRNheapID, "pbPBS", PBScode$, success                   '16Nov00 SF used code from previous selection list
            Else
               Heap 10, gPRNheapID, "pbPBS", solventPBScode$, success
            End If
         Else
            Heap 10, gPRNheapID, "pbPBS", debugPBScode$, success
         End If
         
         If debugSafetyNet$ = "" Then
            txt$ = Format$(dp!(SafetyNetValue!))
         Else
            txt$ = debugSafetyNet$
         End If
         poundsandpence txt$, False
         Heap 10, gPRNheapID, "pbSNvalue", Trim$(money(5)) & Trim$(txt$), success
         
         If debugPatientCost$ = "" Then
            txt$ = Format$(dp!(PatientCost!))
         Else
            txt$ = debugPatientCost$
         End If
         poundsandpence txt$, False
         Heap 10, gPRNheapID, "pbPatCost", Trim$(money(5)) & Trim$(txt$), success

         DT1.mint = L.StopDate
         minstodate DT1
         DateToString DT1, txt$
         Heap 10, gPRNheapID, "pbExpiry", txt$, success
         
         If PBSItemStatus$ = "D" Then     ' deferred
            Heap 10, gPRNheapID, "pbItemsDisp", "0", success
            Heap 10, gPRNheapID, "pbDeferrTxt", "Original item deferred", success
         Else
            '01Jun07 TH Heap 10, gPRNheapID, "pbItemsDisp", Format$(L.batchnumber), success
            Heap 10, gPRNheapID, "pbItemsDisp", Format$(m_PBSDrugRepeat.NumberOfIssues), success
            Heap 10, gPRNheapID, "pbDeferrTxt", "", success
         End If
         
         Heap 10, gPRNheapID, "pbPrescriberID", Trim$(m_Prescriber.registrationNumber), success
         Heap 10, gPRNheapID, "pbPrescriberName", Trim$(m_Prescriber.name), success
         

         ReDim lines$(5)
         'deflines d.Description, lines$(), "!", 1, 0  XN 4Jun15 98073 New local stores description
         deflines d.LabelDescription, lines$(), "!", 1, 0
         Heap 10, gPRNheapID, "pb1stDesc", lines$(1), success
         Heap 10, gPRNheapID, "pbStrength", lines$(2), success
         If OriginalApprovalNumber$ <> "" Then
            Heap 10, gPRNheapID, "pbOrigApprNum", OriginalApprovalNumber$, success
         Else
            txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "ApprovalNumber", 0)
            Heap 10, gPRNheapID, "pbOrigApprNum", txt$, success
         End If
         Heap 10, gPRNheapID, "pbOrigRxDate", Billitems$(59), success  '18Mar03 TH (PBSv4) Added - now use from billitems$ only
         '16Nov00 SF added to display if "immediate supply" and medicare number
         If dispensStatus$ = "I" Then
            Heap 10, gPRNheapID, "pbImmediate", "Immediate supply necessary", success
         Else
            Heap 10, gPRNheapID, "pbImmediate", "", success
         End If
         '31Jan03 TH (PBSv4) Change here to supply temporary number ? you betcha .Added block
         If Trim$(Billitems$(85)) <> "" Then
            Heap 10, gPRNheapID, "pbMedicareNumber", Trim$(Billitems$(85)), success
         Else
            Heap 10, gPRNheapID, "pbMedicareNumber", Trim$(Billitems$(67)) & Trim$(Billitems$(69)), success  '   "
         End If
         'Expirys
         If Trim$(Billitems$(86)) <> "" Then
            txt$ = Left$(Trim$(Billitems$(86)), 2) & "/" & Mid$(Trim$(Billitems$(86)), 3, 2) & "/" & Right$(Trim$(Billitems$(86)), 2)
         Else
            txt$ = ""
         End If
         Heap 10, gPRNheapID, "pbTempMedicareExp", txt$, success
         If Trim$(Billitems$(70)) <> "" Then
            txt$ = Left$(Trim$(Billitems$(70)), 2) & "/" & Right$(Trim$(Billitems$(70)), 4)
         Else
            txt$ = ""
         End If

         Heap 10, gPRNheapID, "pbMedicareExp", txt$, success
         
         If m_sglExceptionalPrice <> 0 Then
            txt$ = Trim$(money(5)) & Format$(CStr(m_sglExceptionalPrice), "###.00") '23Jul03 TH Added monetary prefix
         Else
            txt$ = ""
         End If
         Heap 10, gPRNheapID, "pbExPrice", txt$, success
         txt$ = Format$(CStr(Transcost), "###.00")
         Heap 10, gPRNheapID, "pbTranscost", Trim$(money(5)) & txt$, success
         
         '16Nov00 SF -----
         parsedate thedate(False, False), txt$, "1", 0
         StringToDate txt$, DT1
         ' if 4 or less repeats then next repeat due in 4 clear days otherwise next repeat due in 20 clear days
         repeatsAllowed = NumberOfRepeats()
         If repeatsAllowed < 5 Then
               DT2.day = 5
            Else
               DT2.day = 21
            End If
         DT2.mint = 0
         AddExpiry DT1, DT2
         DateToString DT1, txt$
         Heap 10, gPRNheapID, "pbNextRpt", txt$, success '31Jan03 TH (PBSv4)

         If Trim$(Billitems$(86)) <> "" Then
            txt$ = Left$(Trim$(Billitems$(86)), 2) & "/" & Mid$(Trim$(Billitems$(86)), 3, 2) & "/" & Right$(Trim$(Billitems$(86)), 2)
         ElseIf Trim$(Billitems$(70)) <> "" Then
            txt$ = Left$(Trim$(Billitems$(70)), 2) & "/" & Right$(Trim$(Billitems$(70)), 4)
         Else
            txt$ = ""
         End If
         Heap 10, gPRNheapID, "pbMNExpiry", txt$, success
         
         If Len(Trim$(Billitems$(89))) = 10 Then
            txt$ = Trim$(Billitems$(89))
         Else
            txt$ = ""
         End If
         Heap 10, gPRNheapID, "pblastissueddate", txt$, success
         
         ' don't print a repeat authorisation form if reg24 or if issuing the last repeat and not deferred
         '01Jun07 TH If PBSItemStatus$ = "R" Or (PBSItemStatus$ <> "D" And L.batchnumber = (repeatsAllowed + 1)) Then printRptAuth = False
         If PBSItemStatus$ = "R" Or (PBSItemStatus$ <> "D" And m_PBSDrugRepeat.NumberOfIssues = (repeatsAllowed + 1)) Then printRptAuth = False
         If printRptAuth Then
            ParseThenPrint "RptAuthorisation", dispdata$ & "\RPTAUTH.RTF", 1, 0
            ReprintFile 3, 1, 0    '04Mar02 TH Added Parameter  (#MOJ#)
         End If
      End If

   End Select

End Sub
Private Sub PBSDrugRepeatWrite()

Dim strParams As String
Dim strPBSDrugRepeat As String


   
   strParams = gTransport.CreateInputParameterXML("PatRecNo", trnDataTypeint, 4, m_PBSDrugRepeat.PatRecNo) & _
               gTransport.CreateInputParameterXML("NumberOfRepeats", trnDataTypeint, 4, m_PBSDrugRepeat.NumberOfRepeats) & _
               gTransport.CreateInputParameterXML("DispensQty", trnDataTypeFloat, 8, m_PBSDrugRepeat.DispensQty) & _
               gTransport.CreateInputParameterXML("QtyOwing", trnDataTypeFloat, 8, m_PBSDrugRepeat.QtyOwing) & _
               gTransport.CreateInputParameterXML("StopDate", trnDataTypeVarChar, 10, m_PBSDrugRepeat.StopDate) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, m_PBSDrugRepeat.Status) & _
               gTransport.CreateInputParameterXML("Type", trnDataTypeVarChar, 1, m_PBSDrugRepeat.Type) & _
               gTransport.CreateInputParameterXML("SpecialAuthorityNum", trnDataTypeVarChar, 50, m_PBSDrugRepeat.SpecialAuthorityNum) & _
               gTransport.CreateInputParameterXML("OriginalDate", trnDataTypeVarChar, 10, m_PBSDrugRepeat.OriginalDate) & _
               gTransport.CreateInputParameterXML("OriginalApprovalNumber", trnDataTypeVarChar, 50, m_PBSDrugRepeat.OriginalApprovalNumber) & _
               gTransport.CreateInputParameterXML("OriginalScriptNumber", trnDataTypeVarChar, 50, m_PBSDrugRepeat.OriginalScriptNumber) & _
               gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, m_PBSDrugRepeat.PBScode) & _
               gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 50, m_PBSDrugRepeat.ManufacturersCode) & _
               gTransport.CreateInputParameterXML("SolventCode", trnDataTypeVarChar, 50, m_PBSDrugRepeat.SolventCode) & _
               gTransport.CreateInputParameterXML("ExceptionalPrice", trnDataTypeFloat, 8, m_PBSDrugRepeat.ExceptionalPrice) & _
               gTransport.CreateInputParameterXML("RepeatInterval", trnDataTypeint, 8, m_PBSDrugRepeat.RepeatInterval) & _
               gTransport.CreateInputParameterXML("OriginalLastIssuedDate", trnDataTypeVarChar, 10, m_PBSDrugRepeat.OriginalLastIssuedDate) & _
               gTransport.CreateInputParameterXML("OriginalTimesIssued", trnDataTypeint, 4, m_PBSDrugRepeat.OriginalTimesIssued) & _
               gTransport.CreateInputParameterXML("ExcepDescription", trnDataTypeVarChar, 50, m_PBSDrugRepeat.ExcepDescription) & _
               gTransport.CreateInputParameterXML("ExcepQty", trnDataTypeint, 4, m_PBSDrugRepeat.ExcepQty) & _
               gTransport.CreateInputParameterXML("VariableQtys", trnDataTypeVarChar, 50, m_PBSDrugRepeat.VariableQtys) & _
               gTransport.CreateInputParameterXML("ACCitem", trnDataTypeVarChar, 50, m_PBSDrugRepeat.ACCitem) & _
               gTransport.CreateInputParameterXML("ItemStatus", trnDataTypeVarChar, 50, m_PBSDrugRepeat.ItemStatus) & _
               gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, m_PBSDrugRepeat.RequestID) & _
               gTransport.CreateInputParameterXML("NonpBS", trnDataTypeBit, 1, m_PBSDrugRepeat.NonpBS)
               
    strParams = strParams & gTransport.CreateInputParameterXML("NumberOfIssues", trnDataTypeint, 4, m_PBSDrugRepeat.NumberOfIssues) & _
                            gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, m_PBSDrugRepeat.DrugID)
   'If m_PBSDrugRepeat.NumberOfRepeats <> -1 Then  'Update
   If m_PBSDrugRepeat.PBSDrugRepeatID > 0 Then
      strParams = gTransport.CreateInputParameterXML("PBSDrugRepeatID", trnDataTypeint, 4, m_PBSDrugRepeat.PBSDrugRepeatID) & strParams
      strPBSDrugRepeat = BillingInterface(g_SessionID, "PBSDrugRepeatUpdate", strParams, 0)
   Else 'Insert
      strPBSDrugRepeat = BillingInterface(g_SessionID, "PBSDrugRepeatInsert", strParams, 0)
      m_PBSDrugRepeat.PBSDrugRepeatID = Val(Mid$(strPBSDrugRepeat, 6)) '15May07 TH Added
   End If
   
End Sub

Private Sub LogTransaction()
' Log the transaction for our records which can then be reported on at a later date
'10Oct99 SF now parses out characters in the drug description that would cause the SQL statement to fall over
'           additional field in the Transaction table that distinguishes between a Pharmac and Private dispensing
'18Nov99 SF now not limited to UK date format settings on PBS "transdate" field
'24Nov99 SF now writes the payment category to the transactions table for PBS
'02Dec99 SF now update serial numbers in PBSItemBillCalcs: as needs to be printed on rpt auth form
'16May00 SF now records the l.prescriptionID for Pharmac (will now be used as the unique# printed on the label)
'16May00 SF now not limited to UK date format settings on Pharmac "transdate" field
'16May00 SF now writes the SAapprovalNumber for Pharmac
'14Jul00 SF added Repeat Dispensing mods
'16Nov00 SF updated/added the data recorded against a PBS transaction
'04Mar02 TH Mods to recorded owed scripts and copayment information (#MOJ#)
'31Jan03 TH (PBSv4) MERGED
'31Jan03 TH Various changes to handle new PBSv4 fields
'08Mar03 TH/ATW Privatised
'01Apr03 TH Various mods to handle exceptional items
'03Apr03 TH Parse ' out of names to protect SQL writes (#66525)

Dim cost1$, cost2$, cost3$, SQL$, tmp$
Dim repeats%, drugType$     ' 16Nov99 SF added
Dim X%, origPrescriberID$   '16Nov00 SF added
Dim strTemp As String  '03Apr03 TH (PBSv4)
Dim strPBSDrugRepeat As String


   On Error GoTo LogTransactionErr

   
      
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("patrecno", trnDataTypeVarChar, 10, pid.recno)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("RxNumber", trnDataTypeint, 4, Labf&)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription)
         
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("DispensingNumber", trnDataTypeint, 4, Val(m_PBSDrugRepeat.NumberOfIssues))
         X = billpatient(18, tmp$)
         If tmp$ <> "" Then
               ' use previous prescriber details
               origPrescriberID$ = Trim$(gPrescriberID$)
               GetPrescriberDetails True, tmp$, 0, m_Prescriber
            Else
               tmp$ = Trim$(gPrescriberID$)
            End If
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("PrescriberID", trnDataTypeVarChar, 10, tmp$)                                     ' prescriber code
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("PrescriberNumber", trnDataTypeVarChar, 15, m_Prescriber.registrationNumber)      ' prescriber number
         If tmp$ <> "" Then GetPrescriberDetails True, origPrescriberID$, 0, m_Prescriber     ' reload current prescriber details
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode)
         'The TransDate can now be  defaulted in the DB
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("DispID", trnDataTypeVarChar, 3, Trim$(UserID$))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, Trim$(ASCTerminalName()))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeint, 4, SiteNumber%)
                  
         If Trim$(Billitems$(53)) = "X" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, m_PBSDrugRepeat.ExcepDescription)
         Else
            tmp$ = d.LabelDescription  ' tmp$ = d.Description XN 4Jun15 98073 New local stores description
            plingparse tmp$, "!"
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, tmp$)
         End If
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Convfact", trnDataTypeint, 4, d.convfact)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Printform", trnDataTypeVarChar, 55, d.PrintformV)
         
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Qty", trnDataTypeFloat, 8, Qty!)
         If PBSItemType$ = "" Then                        '31Jan03 TH (PBSv4) This should be sorted elsewhere and is a consequence of variables not
            If Trim$(UCase$(Billitems$(53))) = "N" Then   '   "               being set properly with the new (v4) way of working.
               PBSItemType$ = "N"                         '   "
            Else                                          '   "
               PBSItemType$ = "P"                         '   "
            End If                                        '   "
         Else
            If Trim$(UCase$(Billitems$(53))) = "X" Then PBSItemType$ = "P"
         End If                                           '   "

         SQL$ = SQL$ & gTransport.CreateInputParameterXML("ItemType", trnDataTypeVarChar, 1, PBSItemType$)
         If Trim$(PBSItemStatus$) = "" Then PBSItemStatus$ = Trim$(UCase$(Billitems$(53)))  '18Mar03 TH (PBSv4) Furkling
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("ItemStatus", trnDataTypeVarChar, 1, PBSItemStatus$)
         If PBSItemStatus$ = "U" Then
            'Reset Unoriginal now to type "P" for possible repeats
            Billitems$(53) = "P"
            PBSItemStatus$ = "P"
         End If
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("BeneficiaryType", trnDataTypeVarChar, 1, BeneficiaryType$)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("safetyNetCard", trnDataTypeVarChar, 1, safetyNetCard$)
         If Trim$(UCase$(BeneficiaryType$)) = "R" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("ConcessionCardNum", trnDataTypeVarChar, 11, m_PBSPatient.RepatriationNumber)
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("ConcessionCardNum", trnDataTypeVarChar, 11, m_PBSPatient.ConcessionNumber)
         End If
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("SafetyNetNumber", trnDataTypeVarChar, 11, m_PBSPatient.SafetyNetNumber)
         If Trim$(OriginalDate$) <> "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("originalrxdate", trnDataTypeVarChar, 10, OriginalDate$)
         ElseIf Trim$(datePrescriptionWritten$) <> "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("originalrxdate", trnDataTypeVarChar, 10, datePrescriptionWritten$)
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("originalrxdate", trnDataTypeVarChar, 10, Format(Now, "DD/MM/YYYY")) '"'" & Format(Now, "DD/MM/YYYY") & "', "   '   "    Put in todays date if this is blank
         End If
         If ((PBSItemType$ = "P" And (Not safeNet)) Or (Trim$(UCase$(Billitems$(53))) = "X")) Then   '    "
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("SerialNumber", trnDataTypeVarChar, 10, serialNumWithPrefix$)
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("SerialNumber", trnDataTypeVarChar, 10, "0")
         End If
         If debugPatientCost$ = "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("PatientCost", trnDataTypeFloat, 8, PatientCost!)
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("PatientCost", trnDataTypeFloat, 8, CDbl(debugPatientCost$))
         End If
         If debugSafetyNet$ = "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("SafetyNetValue", trnDataTypeFloat, 8, SafetyNetValue!)
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("SafetyNetValue", trnDataTypeFloat, 8, CDbl(debugSafetyNet$))
         End If
         If foundDrugitem Or EPItem Then
            If debugPBScode$ = "" Then
               If solventPBScode$ = "" Then
                  SQL$ = SQL$ & gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, PBScode$)
               Else
                  SQL$ = SQL$ & gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, solventPBScode$)
               End If
            Else
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, debugPBScode$)
            End If
            If foundDrugitem Then
               If debugManuCode$ = "" Then
                  SQL$ = SQL$ & gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 2, manuCode$)
               Else
                  SQL$ = SQL$ & gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 2, debugManuCode$)
               End If
            Else
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 2, " ")
            End If
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("PBScode", trnDataTypeVarChar, 5, " ")
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("ManufacturersCode", trnDataTypeVarChar, 2, " ")
         End If
         If (safeNet Or (PBSItemType$ = "N")) And (UCase$(Trim$(Billitems$(53))) <> "X") Then    ' TH Set "X" to "N" (send these to HIC)
            If Billitems$(53) = "O" Then
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("HICstatus", trnDataTypeVarChar, 1, "O")
            Else                                      '    "
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("HICstatus", trnDataTypeVarChar, 1, "X")  ' private rx or nothing to claim back off HIC (ie. patient paid < $20.30)
            End If                                    '    "
         Else
            If PBSItemStatus$ = "O" Then
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("HICstatus", trnDataTypeVarChar, 1, "O") 'added to mark prescription owing
            Else
               SQL$ = SQL$ & gTransport.CreateInputParameterXML("HICstatus", trnDataTypeVarChar, 1, "N") ' mark to send a claim to HIC
            End If
         End If
         repeats = NumberOfRepeats()
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Repeats", trnDataTypeint, 4, repeats)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("AuthorityNumber", trnDataTypeVarChar, 8, Trim$(SpecialAuthorityNum$))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("ItemCost", trnDataTypeFloat, 8, hicprice! * 100)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Caseno", trnDataTypeVarChar, 10, Trim$(pid.caseno))
         strTemp = Trim$(pid.forename)
         plingparse strTemp, "'"
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Forename", trnDataTypeVarChar, 15, Trim$(strTemp))
         strTemp = Trim$(pid.surname)
         plingparse strTemp, "'"
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Surname", trnDataTypeVarChar, 20, Trim$(strTemp))

         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Sex", trnDataTypeVarChar, 1, Trim$(pid.sex))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Title", trnDataTypeVarChar, 5, Trim$(pidExtra.title))
         drugType$ = ""
         If (foundDrugitem) And (Not EPItem) Then drugType$ = UCase$(Trim$(m_PBSProduct.RestrictionFlag))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("DrugType", trnDataTypeVarChar, 1, drugType$)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("DispenseStatus", trnDataTypeVarChar, 1, dispensStatus$)
         
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("PaymentCategory", trnDataTypeVarChar, 1, Trim$(Billitems$(62)))    ' added to write payment category
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("HICclaimNumber", trnDataTypeint, 4, CLng(L.prescriptionid))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Original", trnDataTypeVarChar, 50, Format$(Billitems$(71)))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("FamilyGroupNumber", trnDataTypeint, 4, m_PBSPatient.Familygroupnumber)
         tmp$ = Format$(Transcost!)
         poundsandpence tmp$, False
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("TransCost", trnDataTypeFloat, 8, Val(tmp$))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("Subnumerate", trnDataTypeVarChar, 1, m_PBSPatient.Subnumerate)
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("ExceptionalPrice", trnDataTypeFloat, 8, m_sglExceptionalPrice)
         If (foundDrugitem) And (Not EPItem) Then drugType$ = UCase$(Trim$(m_PBSProduct.DrugTypeCode))
         SQL$ = SQL$ & gTransport.CreateInputParameterXML("DrugTypeCode", trnDataTypeVarChar, 5, drugType$)
         If Trim$(Billitems$(85)) <> "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("MedicareNumber", trnDataTypeVarChar, 15, Billitems$(85))
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("MedicareNumber", trnDataTypeVarChar, 15, "")
         End If
         If Trim$(Billitems$(86)) <> "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("MedicareExpiry", trnDataTypeVarChar, 10, Billitems$(86))
         ElseIf Trim$(Billitems$(70)) <> "" Then
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("MedicareExpiry", trnDataTypeVarChar, 10, Billitems$(70))
         Else
            SQL$ = SQL$ & gTransport.CreateInputParameterXML("MedicareExpiry", trnDataTypeVarChar, 10, "")
         End If

         WriteLog dispdata$ & "\RECOVER.PBS", 0, "", SQL$
         strPBSDrugRepeat = BillingInterface(g_SessionID, "PBSTransactionInsert", SQL$, 0)

      
LogTransactionExit:
   On Error GoTo 0
   Exit Sub

LogTransactionErr:
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: LogTransaction" & cr & "Error: " & Error$ & cr & "Error number: " & Err & cr & cr & "Failed to log transaction"
   Resume LogTransactionExit

End Sub
Public Sub CheckPBSCancelandRecord()
'24May07 TH Written
'Here we know we have issued an item. If we have previously cancelled this as a PBS item them we
'need to look up the PBSDrugRepeat row (if one exists) and market as CANCELLED. Then we can read this
'on every redispense and ensure it is not redispensed as a PBS item.

If m_blnPBSDispenseOn = False Then
'check and cancel repeat rec
End If

End Sub
Public Function BillingPreselectItem() As Boolean
'03Jun07 TH Written
'If billing requires a pre-select item (i.e. For a repeat) then we will do it here.
Dim blnResult As Boolean


blnResult = False
'Just PBS for now
If isPBS() Then
   If m_PBSDrugRepeat.NumberOfIssues > 0 And m_PBSDrugRepeat.DrugID > 0 Then
      blnResult = GetProductNLbyDrugID(m_PBSDrugRepeat.DrugID, d)
   
   End If
   

End If

BillingPreselectItem = blnResult
End Function
Private Sub PrintReceipts()
'16Nov00 SF added to allow different types of receipts to be printed. If more than one type of
'           receipt then user will be given choice otherwise if only one, it will automatically be printed
'16Nov00 SF now allows escaping out of printing
'16Nov00 SF now allows escaping
'08Mar03 TH/ATW Privatised

Dim ans$, choice$, txt$
Dim lines$()
Dim NumItems%, X%


''   Select Case billingtype
''      Case 2:     ' PBS
         ans$ = "Y"
         choice$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "DefaultReceiptChoice", 0)
         NumItems = Val(TxtD(dispdata$ & BillIniFile$, "PBS", "0", "NumReceipts", 0))
         If NumItems > 0 Then
            Do
               frmoptionset 0, "Print a Receipt"
               ReDim lines$(2)
               ' get list of receipts to print (context,filename)
               For X = 1 To NumItems
                  txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "R" & Format$(X), 0)
                  deflines txt$, lines$(), ",", 1, 0
                  frmoptionset 1, Trim$(lines$(1))
               Next
               
               If NumItems > 1 Then
                  ' give user choice of receipts to print
                  frmoptionshow (choice$), choice$
                  frmoptionset 0, ""
               Else
                  ' only one type of receipts so automatically print
                  choice$ = "1"
               End If
   
               If Val(choice$) > 0 Then
                  For X = 1 To NumItems
                     If Mid$(choice$, X, 1) = "1" Then
                        txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "R" & Format$(X), 0)
                        deflines txt$, lines$(), ",", 1, 0                 ' split context and filename
                        If fileexists(lines$(2)) Then
                           ParseThenPrint lines$(1), lines$(2), 1, 0
                        Else
                           popmessagecr "#Patient Billing", "Cannot print: " & lines$(1) & cr & cr & "File: " & lines$(2) & " not found"
                        End If
                     End If
                  Next
                  If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "VerifyPrinting", 0)) Then
                     askwin "?Patient Billing", "Have all the receipts printed correctly?", ans$, k
                     If k.escd Then ans$ = "Y"
                  End If
               End If
            Loop Until (ans$ = "Y") Or (Val(choice$) = 0)
         End If

''         '!!** additional billing types here
''      End Select

End Sub
Private Sub PrintOwingPage()

Dim txt$, success%
Dim strAns As String


   FillHeapDrugInfo gPRNheapID, d, 0
   FillHeapPatientInfo gPRNheapID, pid, pidExtra, pidEpisode, 0
   
''   Select Case billingtype
''      Case 2:
         If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "PrintOwingCard", 0)) Then
            txt$ = Trim$(L.drdirection)
            replace txt$, crlf, Chr$(30), 0
            replace txt$, Chr$(10), Chr$(30), 0
            replace txt$, cr, Chr$(30), 0
            replace txt$, Chr$(30), " \par \tab ", 0
            txt$ = " \par \tab " & txt$
            Heap 10, gPRNheapID, "pbDirections", txt$, 0
            Heap 10, gPRNheapID, "pbQty", Format$(Qty!), success
         
            If OriginalApprovalNumber$ <> "" Then
                  Heap 10, gPRNheapID, "pbOrigRxDate", OriginalDate$, success
                  Heap 10, gPRNheapID, "pbOrigApprNum", OriginalApprovalNumber$, success
               Else
                  Heap 10, gPRNheapID, "pbOrigRxDate", datePrescriptionWritten$, success
                  txt$ = TxtD(dispdata$ & BillIniFile$, "PBS", "", "ApprovalNumber", 0)
                  Heap 10, gPRNheapID, "pbOrigApprNum", txt$, success
               End If
            txt$ = Format$(toDispens!) & " " & Trim$(d.PrintformV) & " with " & Trim$(Billitems$(11)) & " repeats"
            Heap 10, gPRNheapID, "pbRepeatText", txt$, success

            Do
               success = True
               ParseThenPrint "PBSowingPage", dispdata$ & "\PBSOWE.RTF", 1, 0
               If TrueFalse(TxtD(dispdata$ & BillIniFile$, "PBS", "N", "VerifyPrinting", 0)) Then
                  strAns = "N"
                  askwin "?Patient Billing", "Has the owing report been printed?", strAns, k
                  If strAns = "N" Then success = False
               End If
            Loop Until success
         End If
''      Case 3:
''         ' setup array of owing prescriptions to be printed when exiting the PMR
''         transCount = transCount + 1
''         If transCount > 100 Then ReDim Preserve PharmInvBill(transCount)
''         PharmInvBill(transCount).labeldirections = Trim$(L.drdirection)
''         PharmInvBill(transCount).Qty = Format$(toDispens!) & " " & Trim$(d.PrintformV) & " with " & Trim$(Billitems$(11)) & " repeats"
''         txt$ = Trim$(d.Description)
''         plingparse txt$, "!"
''         PharmInvBill(transCount).drugdescription = txt$
''         PharmInvBill(transCount).rxno = Format$(L.prescriptionid)
''         PharmInvBill(transCount).rptNumber = L.batchnumber
''         ' following not used in repeat dispensing so just blank
''         PharmInvBill(transCount).firstPartDesc = ""
''         PharmInvBill(transCount).totalCost = ""
''         PharmInvBill(transCount).pharmacsubsidy = ""
''         PharmInvBill(transCount).copayManuPrem = ""
''         PharmInvBill(transCount).label = Labf&
''   End Select

End Sub
Sub LogDeferredTransaction()
'31Jan03 TH (PBS v4) Added as wrapper to main routine
'31Jan03 TH (PBS v4) MERGED

Dim sgltmpQty As Single, strtmpDebugPatientCost As String, sgltmpPatientCost As Single, strtmpDebugSafetyNetValue As String
Dim sgltmpSafetyNetValue As Single, sgltmpTranscost As Single, sgltmpExceptionalPrice As Single, strtmpSerialNumWithPrefix As String

'record the original values
sgltmpQty = Qty!
strtmpDebugPatientCost = debugPatientCost$
sgltmpPatientCost = PatientCost!
strtmpDebugSafetyNetValue = debugSafetyNet$
sgltmpSafetyNetValue = SafetyNetValue!
sgltmpTranscost = Transcost!
sgltmpExceptionalPrice = m_sglExceptionalPrice
strtmpSerialNumWithPrefix = serialNumWithPrefix$
'set values to be recorded in the transaction record
Qty! = 0
debugPatientCost$ = ""
PatientCost! = 0
debugSafetyNet$ = ""
SafetyNetValue! = 0
Transcost! = 0
m_sglExceptionalPrice = 0
serialNumWithPrefix$ = "0"
'record the transaction
LogTransaction
'reset the original values
Qty! = sgltmpQty
debugPatientCost$ = strtmpDebugPatientCost
PatientCost! = sgltmpPatientCost
debugSafetyNet$ = strtmpDebugSafetyNetValue
SafetyNetValue! = sgltmpSafetyNetValue
Transcost! = sgltmpTranscost
m_sglExceptionalPrice = sgltmpExceptionalPrice
serialNumWithPrefix$ = strtmpSerialNumWithPrefix

End Sub

Private Sub UpdateSerialNumber(ByRef serialnumber As Long, action%, strAlteredBeneficiaryType As String, strAlteredSafetyNetType As String)
'16Nov99 SF added for PBS to generate the unique serial number for current batch of claims
' action:
'     0 = read and increment serial number
'     1 = decrement serial number
'     2 = reset all serial numbers

'31Jan03 TH (PBSv4) Reinstated DRs Bag, but NOT as patient type, only flagged by fact drug is Dr's Bag drug
'                   Introduced convoluted way of identifying dr bagt issues for claims to be edited (resubmit) as
'                   snpdrug not in reference at this point for these items.
'31Jan03 TH (PBSv4) MERGED
'08Mar03 TH/ATW Privatised
'14Jul03 TH Added strAlteredBeneficiaryType as param - this is used from resubmit,where the ben type may not be the current type for the pat
'           This is substituted for the ben type here to allow calcs on the altered be type, but put back before leaving the sub.

Dim snap As Snapshot
Dim SQL$, sql2$, snapOpened%
Dim blnDrBag As Integer  '31Jan03 TH (PBSv4)
Dim strRetainedBeneficiaryType As String  '14Jul03 TH Added
Dim strRetainedSafetyNetType As String  '14Jul03 TH Added

   On Error GoTo UpdateSerialNumberErr
   snapOpened% = False

   strRetainedBeneficiaryType = BeneficiaryType$       '14Jul03 TH Added
   strRetainedSafetyNetType = safetyNetCard$
   If Trim$(strAlteredBeneficiaryType) <> "" Then      '   "
      BeneficiaryType$ = strAlteredBeneficiaryType     '   "
   End If                                              '   "
   If Trim$(strAlteredSafetyNetType) <> "" Then      '   "
      safetyNetCard$ = strAlteredSafetyNetType     '   "
   End If                                              '   "
   
   Select Case action
      ' read and increment serial number
      Case 0:
         If serialnumber = -500 Then                                                '31Jan03 TH (PBSv4) Use -500 as flag to denote
            blnDrBag = True                                                     '   "       DB item from edited Hicc transaction
         ElseIf serialnumber = -1000 Then                                        '   "       (snpdrug not in reference from this call)
            blnDrBag = False                                                    '   "
         ElseIf EPItem Then                                                       '   "
            blnDrBag = False                                                    '   "
         ElseIf Trim$(UCase$(m_PBSProduct.DrugTypeCode)) = "DB" Then         '   "
            blnDrBag = True                                                     '   "
         End If
         If blnDrBag Then                                                                 '31Jan03 TH (PBSv4) Now selected above
''                 sql$ = "SELECT doctorsbag AS currentnumber FROM serialnumbers;"          '    "
''                 sql2$ = "UPDATE serialnumbers SET doctorsbag = doctorsbag + 1;"          '    "
            GetPointerSQL dispdata$ & "\PBSDoctorsBag", serialnumber, True
         'If safetyNetCard$ = "C" Or safetyNetCard$ = "E" Then                            '    "
         ElseIf safetyNetCard$ = "C" Or safetyNetCard$ = "E" Then                         '    "
            If safetyNetCard$ = "C" Then
''                     sql$ = "SELECT concessional AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET concessional = concessional + 1;"
               GetPointerSQL dispdata$ & "\PBSConcessional", serialnumber, True
            ElseIf BeneficiaryType$ = "R" Then
''                     sql$ = "SELECT repatriation AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET repatriation = repatriation + 1;"
               GetPointerSQL dispdata$ & "\PBSRepatriation", serialnumber, True
            Else
''                     sql$ = "SELECT entitlement AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET entitlement = entitlement + 1;"
               GetPointerSQL dispdata$ & "\PBSEntitlement", serialnumber, True
            End If
         Else
            Select Case BeneficiaryType$
               Case "G":
''                     sql$ = "SELECT generalpatients AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET generalpatients = generalpatients + 1;"
                  GetPointerSQL dispdata$ & "\PBSGeneralpatients", serialnumber, True
               Case "C":
''                     sql$ = "SELECT concessional AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET concessional = concessional + 1;"
                  GetPointerSQL dispdata$ & "\PBSConcessional", serialnumber, True
               Case "R":
''                     sql$ = "SELECT repatriation AS currentnumber FROM serialnumbers;"
''                     sql2$ = "UPDATE serialnumbers SET repatriation = repatriation + 1;"
                  GetPointerSQL dispdata$ & "\PBSRepatriation", serialnumber, True
            End Select
         End If
''         Set snap = Patdb.CreateSnapshot(sql$)
''         snapOpened% = True
''         If Not snap.EOF Then
''               serialnumber& = GetField(snap!currentnumber)
''            Else
''               ' **!! should never happen
''               serialnumber& = 0
''            End If
''         snap.Close: Set snap = Nothing
''         DoSaferEvents 1
''         WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql2$
''         Patdb.Execute (sql2$)
''         DoSaferEvents 1
''         snapOpened% = False
                                                    
      ' decrement serial number
      Case 1:
         If Trim$(UCase$(m_PBSProduct.DrugTypeCode)) = "DB" Then                '31Jan03 TH (PBSv4)
''            sql$ = "UPDATE serialnumbers SET doctorsbag = doctorsbag -1;"         '    "
            GetPointerSQL dispdata$ & "\PBSDoctorsbag", serialnumber, 1
         'If safetyNetCard$ = "C" Or safetyNetCard$ = "E" Then                       '    "
         ElseIf safetyNetCard$ = "C" Or safetyNetCard$ = "E" Then                    '    "
            If BeneficiaryType$ = "R" Then
''                     sql$ = "UPDATE serialnumbers SET repatriation = repatriation - 1;"
               GetPointerSQL dispdata$ & "\PBSRepatriation", serialnumber, 1
            Else
''                     sql$ = "UPDATE serialnumbers SET entitlement = entitlement -1;"
               GetPointerSQL dispdata$ & "\PBSEntitlement", serialnumber, 1
            End If
         Else
            Select Case BeneficiaryType$
''                  Case "G": sql$ = "UPDATE serialnumbers SET generalpatients = generalpatients -1;"
''                  Case "C": sql$ = "UPDATE serialnumbers SET concessional = concessional -1;"
''                  Case "R": sql$ = "UPDATE serialnumbers SET repatriation = repatriation -1;"
               Case "G": GetPointerSQL dispdata$ & "\PBSGeneralpatients", serialnumber, 1
               Case "C": GetPointerSQL dispdata$ & "\PBSConcessional", serialnumber, 1
               Case "R": GetPointerSQL dispdata$ & "\PBSRepatriation", serialnumber, 1
            End Select
         End If
         
''         WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''         Patdb.Execute (sql$): DoSaferEvents 1

      ' reset all serial numbers
      Case 2:
         'Should be done from CTS/End of year PBS job
''         sql$ = "UPDATE serialnumbers SET doctorsbag = 1, generalpatients = 1, concessional = 1, entitlement = 1, repatriation = 1;"
''         WriteLog dispdata$ & "\RECOVER.PBS", 0, "", sql$
''         Patdb.Execute (sql$): DoSaferEvents 1
   End Select


UpdateSerialNumberExit:
   On Error Resume Next                               '14Jul03 TH Added
   BeneficiaryType$ = strRetainedBeneficiaryType      '    "
   safetyNetCard$ = strRetainedSafetyNetType
   On Error GoTo 0                                    '    "
''   If snapOpened% Then
''         On Error Resume Next
''         snap.Close
''         Set snap = Nothing
''      End If
   On Error GoTo 0
   Exit Sub

UpdateSerialNumberErr:
   serialnumber = 0
   'WriteLog patdatapath$ & BillLogFile$, SiteNumber%, userid$, "Program Error (Procedure: UpdateSerialNumber) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(labf&) & " Error: " & Error$ & cr & "Error number: " & Err                '16May00 SF replaced
   WriteLog dispdata$ & BillLogFile$, SiteNumber%, UserID$, "Program Error (Procedure: UpdateSerialNumber) for PatRecNo: " & Trim$(pid.recno) & " ,RxNo: " & Format$(L.prescriptionid) & " Error: " & Error$ & cr & "Error number: " & Err      '16May00 SF
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: UpdateSerialNumber" & cr & "Error: " & Error$ & cr & "Error number: " & Err
   Resume UpdateSerialNumberExit

End Sub

Private Function GetSerialPrefix(blnDrBag As Integer, strAlteredBeneficiaryType As String, strAlteredSafetyNetType As String) As String
'Function GetSerialPrefix$ (authority%, deferred%)
'16Nov99 SF returns a prefix to to the claim serial number depending on the prescription/card type
'16Nov00 SF new logic as benificiary cards and safety net cards now used separate variables
'31Jan03 TH (PBSv4) Add DrsBag parameter as snpdrug not in reference when resubmitting claims
'31Jan03 TH (PBSv4) MERGED
'08Mar03 TH/ATW Privatised
'14Jul03 TH Added mod and parameters to allow ben type and safety net type to be substituted here and returned after the serial
'           number is generated.This is necessary for resubmits when past info has now been superceeded.

Dim prefix$
Dim strRetainedBeneficiaryType As String
Dim strRetainedSafetyNetType As String

   strRetainedBeneficiaryType = BeneficiaryType$
   strRetainedSafetyNetType = safetyNetCard$
   If Trim$(strAlteredBeneficiaryType) <> "" Then
      BeneficiaryType$ = strAlteredBeneficiaryType
   End If
   If Trim$(strAlteredSafetyNetType) <> "" Then
      safetyNetCard$ = strAlteredSafetyNetType
   End If


   prefix$ = ""
   If blnDrBag Then
      prefix$ = "DB"
   ElseIf Trim$(safetyNetCard$) <> "" Then
      If Trim$(BeneficiaryType$) = "R" Then
         prefix$ = "RE"
      ElseIf safetyNetCard$ = "C" Then
         prefix$ = "C"
      Else
         prefix$ = "E"
      End If
   Else
      Select Case Trim$(BeneficiaryType$)
         Case "C": prefix$ = "C"
         Case "R": prefix$ = "R"
      End Select
   End If

   GetSerialPrefix = prefix$

   On Error Resume Next
   BeneficiaryType$ = strRetainedBeneficiaryType
   safetyNetCard$ = strRetainedSafetyNetType
   On Error GoTo 0


End Function




