Attribute VB_Name = "PCT"
'16Nov11 TH Written.          BAS to support PCT Specific routines and functions

'Includes all ocx PCT specific business logic , IO layer and Wrappers for PCT UI
'15Sep15 XN 51497 LogPCTClaimTransaction: set extra fields to null is wastage

DefInt A-Z
Option Explicit


Dim m_NumericDose As Single
Dim m_blnPCTDispensing As Boolean 'Main check that PCT is currently active for this process
Dim m_intCourseDays As Integer

Type PCTProduct
   PCTProductID As Long
   PCTMasterProductID As Long
   BrandCode As Long
   BrandName As String * 40
   FormulationName As String * 200
   ChemicalName As String * 240
   Pharmacode As Long
   quantity As Double
   Multiple As Double
   Specified As Boolean
   Subsidy As Double
   Alternate As Double
   Price As Double
   CBS As Boolean
   OP As Boolean
   SpecialType As String * 25
   SpecialEndorsementType As String * 25
   Units As String * 5
   ScheduleDate As Date
End Type

Type PCTPatient
   PCTPatientID As Long
   EntityID As Long
   HUHCNo As String * 10
   HUHCExpiry As Date
   CSC As Boolean
   CSCExpiry As Date
   PermResHokianga As Boolean
   PHORegistered As Boolean
   NHINumber As String * 7
   dob As Date
End Type

Type PCTIngredient
   'Qty As Long
   Qty As Single '01Mar12 TH Altered TFS 28181
   'WastageQty As Long
   WastageQty As Single
   Pharmacode As Long
   'Dose As Long
   'dailydose As Long
   dose As Single
   dailydose As Single
End Type

Type PCTPrescription
   PCTPrescriptionID As Long
   PrescriberEntityID As Long
   PrescriptionFormNumber As Long
   SpecialAuthorityNumber As String * 10 '12Jan12 TH Extended from 5
   SpecialistEndorserNZMCNumber As String * 10
   PrescriberNZMCNumber As String * 10
   fullWastage As Boolean
   EndorsementDate As Date
   PCTOncologyPatientGroupingCode As String * 1
   'PCTOncologyPatientGroupingID As Long
   PrescriberName As String * 50
   EndorserName As String * 50
   PCTOncologyPatientGrouping As String * 50
End Type

Type PCTClaimTransaction
   Category As String * 1
   PrescriberID As String * 10
   HealthProfessionalGroupCode As String * 2
   SpecialistID As String * 10
   EndorsementDate As Date
   PrescriberFlag As String * 1
   PCTOncologyPatientGroupingCode As String * 1
   NHI As String * 7
   PCTPatientCategory As String * 1
   CSCorPHOStatusFlag As String * 1
   HUHCStatusFlag As Boolean
   SpecialAuthorityNumber As String * 10
   dose As Single
   dailydose As Single
   PrescriptionFlag As Boolean
   DoseFlag As Boolean
   PrescriptionID As String * 9
   ServiceDate As Date
   ClaimCode As Long  'This is the Pharmacode !!
   QuantityClaimed As Single
   PackUnitOfMeasure As String * 8
   ClaimAmount As Single
   CBSSubsidy As Single
   CBSPacksize As Single
   Funder As String * 3
   FormNumber As Long
   PCTTransactionStatusID As Long
   ScheduleDate As Date
End Type


Dim m_PCTIngredients() As PCTIngredient

Dim m_PCTProduct As PCTProduct
Dim m_PCTPatient As PCTPatient
Dim m_intIngredients As Integer
Dim m_PCTPrescription As PCTPrescription
Dim m_PCTClaimTransaction As PCTClaimTransaction
Dim m_blnPCTPRN As Boolean '05Jan12 TH
Dim m_blnPCTNoCourseLength As Boolean '05Jan12 TH
Dim m_blnPCTStat As Boolean '05Jan12 TH






Sub setPCTDose(ByVal NumericDose As Single, ByVal intDays As Integer, ByVal blnDontFactor As Boolean)
'16Nov11 TH Written based on PBS Chemo work


   If d.LabelInIssueUnits And Not (blnDontFactor) Then
      m_NumericDose = NumericDose * d.dosesperissueunit
   Else
      m_NumericDose = NumericDose
   End If
   'm_intCourseDays = intDays '06Jan12 TH Removed as this is now derive purley from the direction
End Sub

Function getPCTDose() As Single
'16Nov11 TH Written based on PBS Chemo work

   getPCTDose = m_NumericDose
End Function

Function PCTDrugToDispens()

   PCTDrugToDispens = False

   If m_blnPCTDispensing = True Then
      'If ItemForBilling() And (Val(TxtD(dispdata$ & "\patbill.ini", "PCT", "N", "PCTBilling", 0)) = 2) Then PBSDrugToDispens = True
      'Check here we have a valid PCT ingredient line (Primary) in scope. Plus any other
      PCTDrugToDispens = True
   End If
   
End Function

Function InitialisePCTBilling()
'21Nov11 TH Written
'This function is calle to test whether PCT is on and going to be used. It should check for configuration
'and then ensure we have access to data that should have been collected outside the ocx.
'We then set the global PCT flag, which can then get turned off seperately by various user action.
'Returns whether we are potentially able to do PCT Claiming or not

Dim strParams As String
Dim rsPCTRxData As ADODB.Recordset
Dim rsPCTPatientData As ADODB.Recordset



InitialisePCTBilling = False

If TrueFalse(TxtD(dispdata$ & "\patbill.ini", "PCT", "N", "PCTBilling", 0)) Then
   'OK we are configured - now read the DB for linked data. If found store here and set PCT Flag
   strParams = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription)
   Set rsPCTRxData = gTransport.ExecuteSelectSP(g_SessionID, "pPCTPrescriptionbyRequestIDforDispensingClaim", strParams)
   If Not rsPCTRxData.EOF Then
      rsPCTRxData.MoveFirst
      'Read the data into the PCTPrescription type
      m_PCTPrescription.EndorsementDate = RtrimGetField(rsPCTRxData!EndorsementDate)
      m_PCTPrescription.fullWastage = RtrimGetField(rsPCTRxData!fullWastage)
      m_PCTPrescription.PCTPrescriptionID = RtrimGetField(rsPCTRxData!PCTPrescriptionID)
      m_PCTPrescription.PrescriberEntityID = RtrimGetField(rsPCTRxData!PrescriberEntityID)
      m_PCTPrescription.PrescriberNZMCNumber = RtrimGetField(rsPCTRxData!PrescriberNZMCNumber)
      m_PCTPrescription.SpecialistEndorserNZMCNumber = RtrimGetField(rsPCTRxData!SpecialistEndorserNZMCNumber)
      m_PCTPrescription.PCTOncologyPatientGroupingCode = RtrimGetField(rsPCTRxData!PCTOncologyPatientGroupingCode)
      'm_PCTPrescription.PCTOncologyPatientGroupingID = RtrimGetField(rsPCTRxData!PCTOncologyPatientGroupingID)
      m_PCTPrescription.PrescriberName = RtrimGetField(rsPCTRxData!PrescriberFullname)
      m_PCTPrescription.EndorserName = RtrimGetField(rsPCTRxData!SpecEndorserFullname)
      m_PCTPrescription.PrescriptionFormNumber = RtrimGetField(rsPCTRxData!PrescriptionFormNumber)
      m_PCTPrescription.PCTOncologyPatientGrouping = RtrimGetField(rsPCTRxData!PCTOncologyPatientGrouping)
      m_PCTPrescription.SpecialAuthorityNumber = RtrimGetField(rsPCTRxData!SpecialAuthorityNumber)
      m_blnPCTDispensing = True 'Set flag as we are good to go
   End If
   rsPCTRxData.Close
   Set rsPCTRxData = Nothing
   
   If m_blnPCTDispensing Then
   
      
   
      'Now we should load the patient, again no patient, no go
      m_blnPCTDispensing = False
      'If CLng(OCXheap("EntityID", "0")) > 0 Then '29Nov11 TH EntityID here is user not patient
      If Val(pid.recno) > 0 Then
         'strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, CLng(OCXheap("EntityID", "0"))) '29Nov11 TH EntityID here is user not patient
         strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, pid.recno)
         
         Set rsPCTPatientData = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyPCTPatientByEntityID", strParams)
         If Not rsPCTPatientData.EOF Then
            rsPCTPatientData.MoveFirst
            'Read the data into the PCTPatient type
            m_PCTPatient.CSC = RtrimGetField(rsPCTPatientData!CSC)
            m_PCTPatient.CSCExpiry = RtrimGetField(rsPCTPatientData!CSCExpiry)
            m_PCTPatient.EntityID = RtrimGetField(rsPCTPatientData!EntityID)
            m_PCTPatient.HUHCExpiry = RtrimGetField(rsPCTPatientData!HUHCExpiry)
            m_PCTPatient.HUHCNo = RtrimGetField(rsPCTPatientData!HUHCNo)
            m_PCTPatient.PCTPatientID = RtrimGetField(rsPCTPatientData!PCTPatientID)
            m_PCTPatient.PermResHokianga = RtrimGetField(rsPCTPatientData!PermResHokianga)
            m_PCTPatient.PHORegistered = RtrimGetField(rsPCTPatientData!PHORegistered)
            m_PCTPatient.NHINumber = RtrimGetField(rsPCTPatientData!NHINumber)
            m_PCTPatient.dob = RtrimGetField(rsPCTPatientData!dob)
            m_blnPCTDispensing = True 'Set flag as we are good to go
         End If
         rsPCTPatientData.Close
         Set rsPCTPatientData = Nothing
      End If
   End If
   
   
   InitialisePCTBilling = m_blnPCTDispensing
   
End If



End Function
Function PCTConfirmClaimQty(ByVal sglIssueQty As Single) As Boolean
'This will be a wrapper for a data capture screen to show the user the calculated
'Qty for the claim and allow them to edit.
'this could also be used to capture secondary items and quantities too.

'To display - Some form of PBS description. PBSCode. Qty for claim. Max Qty under schedule. Dosing unit.

'secondarys.
'Also need validation on maxqty with possible capture of authority number.
'Should still be able to cancel here if over maxqty and authority number already supplied

'24Jan12 TH Now check to see if we are claiming in issue unit equivalents.

'Load up the Form

Dim frm As FrmPCTQTY
Dim lclQty!, checkQty As Long
Dim blnEscd As Boolean
Dim blnReturn As Boolean
Dim sglTotalDose As Single
Dim sglPrimaryWastage As Single
Dim strParams As String
Dim rsSecondaryIngredients As ADODB.Recordset
Dim intloop As Integer
Dim sglDose As Single
Dim sglDailyDose As Single
Dim blnIssueUnitConversion As Boolean


   blnReturn = False 'This is effectively an escape flag
   blnIssueUnitConversion = False
   
   Set frm = New FrmPCTQTY
   
   'Sort the active ingredient
   frm.lblDescription.Caption = Trim$(m_PCTProduct.ChemicalName) & " " & Trim$(m_PCTProduct.FormulationName) '14Feb12 TH TFS26923 Added space
   frm.lblPharmacode.Caption = m_PCTProduct.Pharmacode
   frm.lblUnits.Caption = Trim$(m_PCTProduct.Units)  ' d.DosingUnits '24Jan12 TH Replaced
   If getPCTPRNflag() Then
      frm.lblInfo = "As this is a PRN Prescription it is not possible to automatically calculate PCT claim quantities. In order to create a PCT claim you will need to enter the required quantities here."
   ElseIf getPCTNoCourseLengthflag And (Not getPCTStatflag()) Then
      frm.lblInfo = "As this is a Prescription with no course length in the directions it is not possible to automatically calculate PCT claim quantities. In order to create a PCT claim you will need to enter the required quantities here."
   End If
   
   lclQty! = getPCTDose()
   'If d.LabelInIssueUnits Then
   '   frm.txtQtyToClaim = Format(lclQty!, "#######0")
   'Else
   
   'Check here to see whether we should claim in issue units
   If InStr(1, "," & LCase$(TxtD(dispdata$ & "\patbill.ini", "PCT", ",tab,inj,cap,txpk,", "IssueConvUnits", 0)) & ",", "," & Trim$(LCase$(m_PCTProduct.Units)) & ",", 1) > 0 Then blnIssueUnitConversion = True
   If Not blnIssueUnitConversion Then
      'extra check for the wierdies
      If LCase$(TxtD(dispdata$ & "\patbill.ini", "PCTIssueConvExceptions", "", LCase(d.SisCode), 0)) = Trim$(LCase$(m_PCTProduct.Units)) Then blnIssueUnitConversion = True
   End If
   If blnIssueUnitConversion Then lclQty! = lclQty! / d.dosesperissueunit
   
   If m_PCTPrescription.fullWastage Or getPCTPRNflag() Or (getPCTNoCourseLengthflag And (Not getPCTStatflag())) Then
      frm.txtQtyToClaim.text = "0"
   Else
      frm.txtQtyToClaim.text = Format(lclQty!, "#######0.####")
      frm.txtQtyToClaim.text = Format$(frm.txtQtyToClaim.text)
   End If
      'THis was an exclusion for repeats on PBS (couldnt change the original qty
      'If m_PCTProduct.NumberOfIssues > 0 Then
      '   frm.txtQtyToClaim.Enabled = False
      'End If
   'End If
   checkQty = frm.txtQtyToClaim.text
   'Now we have our active amt, we need to calculate and show for edit our esitimated partial wastage amt.
   
   'We first take the issue qty and generate a total dose
   If blnIssueUnitConversion Then
      sglTotalDose = sglIssueQty
   Else
      sglTotalDose = sglIssueQty * d.dosesperissueunit
   End If
   
   sglPrimaryWastage = sglTotalDose - lclQty!
   If getPCTPRNflag() Or (getPCTNoCourseLengthflag And (Not getPCTStatflag())) Then sglPrimaryWastage = 0
   
   If sglPrimaryWastage < 0 Then sglPrimaryWastage = 0
   If m_PCTPrescription.fullWastage Then
      frm.txtWastageQty.text = Format(sglTotalDose, "#######0.####")
      frm.txtWastageQty.text = Format$(frm.txtWastageQty.text)

      frm.TxtDose.Visible = False
      frm.txtDailyDose.Visible = False
      frm.txtQtyToClaim.Visible = False
   Else
      frm.txtWastageQty.text = Format(sglPrimaryWastage, "#######0.####")
      frm.txtWastageQty.text = Format$(frm.txtWastageQty.text)
      frm.TxtDose.Visible = True
      frm.txtDailyDose.Visible = True
      frm.txtQtyToClaim.Visible = True
   End If
   
   'And finally there are the dose fields (this is dose for a given administration
   'and the daily dose (avg dose per day) ie qty/course length in days)
   
   'Use l.dose ? yes - must ensure that asymetric dosing not included here
   If d.LabelInIssueUnits Then
   'If d.LabelInIssueUnits And (Not blnIssueUnitConversion) Then '24Jan12 TH Replaced above
   
      sglDose = L.dose(1) * d.dosesperissueunit
      
   Else
      sglDose = L.dose(1)
   End If
   
   If blnIssueUnitConversion Then sglDose = sglDose / d.dosesperissueunit
   
   
   If getPCTPRNflag() Or (getPCTNoCourseLengthflag And (Not getPCTStatflag())) Then
      sglDose = 0
      sglTotalDose = 0
      lclQty = 0
   End If
   If Not m_PCTPrescription.fullWastage Then
      frm.TxtDose.text = Format(sglDose, "#######0.####")
      frm.TxtDose.text = Format$(frm.TxtDose.text)
      If m_intCourseDays = 0 Then m_intCourseDays = 1   '13Dec11 TH TFS 21049
      'sglDailyDose = sglTotalDose / m_intCourseDays
      sglDailyDose = lclQty / m_intCourseDays      '11Jan12 TH Daily dose should be a factor of the prescribed dose (claimable) rather than the toatl dose issued.
      frm.txtDailyDose.text = Format(sglDailyDose, "#######0.####")
      frm.txtDailyDose.text = Format$(frm.txtDailyDose.text)
   End If
   
   m_intIngredients = 1
   ReDim m_PCTIngredients(m_intIngredients)
   m_PCTIngredients(m_intIngredients).dailydose = 0
   m_PCTIngredients(m_intIngredients).dose = 0
   m_PCTIngredients(m_intIngredients).Pharmacode = m_PCTProduct.Pharmacode
   
   If Not m_PCTPrescription.fullWastage Then
      m_PCTIngredients(m_intIngredients).Qty = checkQty
   Else
      m_PCTIngredients(m_intIngredients).Qty = 0
   End If
   
   m_PCTIngredients(m_intIngredients).WastageQty = Val(frm.txtWastageQty.text)
   
   'Now load up secondaries. This is an important part of the process aove and
   'beyond the simple capture of qtys. WEstore an array of secondaries and related information for
   'The purposes of writing extra claims later on.
   strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
      & gTransport.CreateInputParameterXML("Primary", trnDataTypeBit, 1, 0)
   
   Set rsSecondaryIngredients = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductbyProductstockIDandPrimary", strParams)
   If Not rsSecondaryIngredients.EOF Then
      frm.LblSecondaryIngredients.Visible = True
      rsSecondaryIngredients.MoveFirst
      Do While (Not rsSecondaryIngredients.EOF)
         If m_intIngredients > 3 Then Exit Do
         'Load the controls first
         frm.LabelDescSecondary(m_intIngredients - 1).Visible = True
         frm.lblSecondaryPharmacode(m_intIngredients - 1).Visible = True
         If Not m_PCTPrescription.fullWastage Then
         frm.txtSecondaryDose(m_intIngredients - 1).Visible = True
         frm.txtSecondaryDailyDose(m_intIngredients - 1).Visible = True
         frm.txtSecondaryQty(m_intIngredients - 1).Visible = True
         End If
         frm.txtWastegeQtySecondary(m_intIngredients - 1).Visible = True
         frm.lblUnitsSecondary(m_intIngredients - 1).Visible = True
         'Fill out details
         'frm.LabelDescSecondary(m_intIngredients - 1).Caption = RtrimGetField(rsSecondaryIngredients!ChemicalName) & " " & RtrimGetField(rsSecondaryIngredients!Formulation)
         frm.LabelDescSecondary(m_intIngredients - 1).Caption = RtrimGetField(rsSecondaryIngredients!ChemicalName) & " " & RtrimGetField(rsSecondaryIngredients!FormulationName)  '21Mar12 TH altered field name.
         frm.lblSecondaryPharmacode(m_intIngredients - 1).Caption = RtrimGetField(rsSecondaryIngredients!Pharmacode)
         frm.lblUnitsSecondary(m_intIngredients - 1).Caption = RtrimGetField(rsSecondaryIngredients!Units)
         
         
         'Now store the Pharmacodes
         m_intIngredients = m_intIngredients + 1
         ReDim Preserve m_PCTIngredients(m_intIngredients)
         m_PCTIngredients(m_intIngredients).dailydose = 0
         m_PCTIngredients(m_intIngredients).dose = 0
         m_PCTIngredients(m_intIngredients).Pharmacode = RtrimGetField(rsSecondaryIngredients!Pharmacode)
         m_PCTIngredients(m_intIngredients).Qty = 0
         m_PCTIngredients(m_intIngredients).WastageQty = 0
         
         rsSecondaryIngredients.MoveNext
         
      Loop
      
   End If
   '----------------
   
   '09Jan12 TH now load new rx stuff
   frm.lblPrescriber.Caption = m_PCTPrescription.PrescriberName
   frm.lblEndorsementDate.Caption = m_PCTPrescription.EndorsementDate
   If Trim$(frm.lblEndorsementDate.Caption) = "00:00:00" Then frm.lblEndorsementDate.Caption = ""
   frm.lblOncologyGroup.Caption = m_PCTPrescription.PCTOncologyPatientGrouping
   frm.lblPrescriptionFormNumber.Caption = m_PCTPrescription.PrescriptionFormNumber
   frm.lblSpecialistEndorser.Caption = m_PCTPrescription.EndorserName
   frm.lblSpecialAuthorityNumber.Caption = m_PCTPrescription.SpecialAuthorityNumber
   '--------------------------------
   
   frm.Tag = ""
   'Need to mask input
   'frm.cmdCancel.SetFocus
   frm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

   If frm.Tag = "OK" Then
   
      'First do an authority check
      'blnEscd = billpatient(36, frm.txtQtyToClaim.text)
      'If checkQty <> Val(frm.txtQtyToClaim) Then
      '   'Change Qty
      '   'This is in units so dont factor !!
      '   setPCTDose Val(frm.txtQtyToClaim), True
      '   'm_PBSDrugRepeat.DispensQty = frm.txtQtyToClaim 'No PCT Equivalent (yet)
      'End If
      
      'Loop through and store the values for the claim
      m_PCTIngredients(1).dailydose = Val(frm.txtDailyDose.text)
      m_PCTIngredients(1).dose = Val(frm.TxtDose.text)
      m_PCTIngredients(1).Qty = Val(frm.txtQtyToClaim.text)
      m_PCTIngredients(1).WastageQty = Val(frm.txtWastageQty.text)
      If m_intIngredients > 1 Then 'WE have secondary ingredients
         For intloop = 2 To m_intIngredients
            m_PCTIngredients(intloop).dailydose = Val(frm.txtSecondaryDailyDose(intloop - 2).text)
            m_PCTIngredients(intloop).dose = Val(frm.txtSecondaryDose(intloop - 2).text)
            m_PCTIngredients(intloop).Qty = Val(frm.txtSecondaryQty(intloop - 2).text)
            m_PCTIngredients(intloop).WastageQty = Val(frm.txtWastegeQtySecondary(intloop - 2).text)
         Next
      End If
      blnReturn = blnEscd
   
   Else
      'We need to set a cancel flag
      blnReturn = True
   End If
 

   PCTConfirmClaimQty = blnReturn


End Function

Private Sub LogPCTClaimTransaction(ByRef PCTClaim As PCTClaimTransaction)
'Log the transaction for our records which can then be reported on at a later date
'Wastage inferred by PCTPatientCategory field
'15Sep15 XN 51497 set extra fields to null is wastage

Dim cost1$, cost2$, cost3$, SQL$, tmp$
Dim repeats%, drugType$
Dim X%, origPrescriberID$
Dim strTemp As String
Dim strHospitalProviderNumber As String
Dim lngOK As Long
Dim lngPCTTransaction As Long


Dim strParams As String

   'If getPBSLabelsOnly() Then Exit Sub  '21Sep09 TH Added for NTHS who want to be able to do an entire re-issue efectively cos they made a spelling mistake (but not change the data of course !!! (F0053470)
    
   On Error GoTo LogPCTClaimTransactionErr

   
         strParams = ""
         strParams = strParams & gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) '08Feb12 THWas ClaimfileID - this is now done in the sp itself
         strParams = strParams & gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 1, "I")
         strParams = strParams & gTransport.CreateInputParameterXML("ComponentNumber", trnDataTypeint, 4, "1")
         strParams = strParams & gTransport.CreateInputParameterXML("TotalComponentNumber", trnDataTypeint, 4, "1")
         If PCTClaim.PCTPatientCategory = "W" Then  '15Sep15 XN 51497 set extra fields to null is wastage
             strParams = strParams & gTransport.CreateInputParameterXML("PrescriberID", trnDataTypeVarChar, 10, Null)
             strParams = strParams & gTransport.CreateInputParameterXML("HealthProfessionalGroupCode", trnDataTypeVarChar, 2, Null)
         Else
             strParams = strParams & gTransport.CreateInputParameterXML("PrescriberID", trnDataTypeVarChar, 10, Trim$(PCTClaim.PrescriberID))
             strParams = strParams & gTransport.CreateInputParameterXML("HealthProfessionalGroupCode", trnDataTypeVarChar, 2, Trim$(PCTClaim.HealthProfessionalGroupCode))
         End If
         strParams = strParams & gTransport.CreateInputParameterXML("SpecialistID", trnDataTypeVarChar, 10, Trim$(PCTClaim.SpecialistID))
         If PCTClaim.PCTPatientCategory = "W" Then
            strParams = strParams & gTransport.CreateInputParameterXML("EndorsementDate", trnDataTypeDateTime, 4, Null)
            strParams = strParams & gTransport.CreateInputParameterXML("PrescriberFlag", trnDataTypeVarChar, 1, Null)
            strParams = strParams & gTransport.CreateInputParameterXML("PCTOncologyPatientGroupingCode", trnDataTypeChar, 1, Null)
         Else
            strParams = strParams & gTransport.CreateInputParameterXML("EndorsementDate", trnDataTypeDateTime, 4, PCTClaim.EndorsementDate)
            strParams = strParams & gTransport.CreateInputParameterXML("PrescriberFlag", trnDataTypeVarChar, 1, Trim$(PCTClaim.PrescriberFlag))
            strParams = strParams & gTransport.CreateInputParameterXML("PCTOncologyPatientGroupingCode", trnDataTypeChar, 1, Trim$(PCTClaim.PCTOncologyPatientGroupingCode))
         End If
         'strParams = strParams & gTransport.CreateInputParameterXML("PCTOncologyPatientGroupingCode", trnDataTypeint, 4, 0)
         strParams = strParams & gTransport.CreateInputParameterXML("NHI", trnDataTypeVarChar, 7, Trim$(PCTClaim.NHI))
         strParams = strParams & gTransport.CreateInputParameterXML("PCTPatientCategory", trnDataTypeVarChar, 1, Trim$(PCTClaim.PCTPatientCategory))
         If PCTClaim.PCTPatientCategory = "W" Then
            strParams = strParams & gTransport.CreateInputParameterXML("CSCorPHOStatusFlag", trnDataTypeVarChar, 1, Null)   '15Sep15 XN 51497 set extra fields to null is wastage
            strParams = strParams & gTransport.CreateInputParameterXML("HUHCStatusFlag", trnDataTypeBit, 1, Null)
         Else
            strParams = strParams & gTransport.CreateInputParameterXML("CSCorPHOStatusFlag", trnDataTypeVarChar, 1, Trim$(PCTClaim.CSCorPHOStatusFlag))
            strParams = strParams & gTransport.CreateInputParameterXML("HUHCStatusFlag", trnDataTypeBit, 1, PCTClaim.HUHCStatusFlag)
         End If
         strParams = strParams & gTransport.CreateInputParameterXML("SpecialAuthorityNumber", trnDataTypeVarChar, 10, Trim$(PCTClaim.SpecialAuthorityNumber)) '12Jan12 TH Reinstated
         strParams = strParams & gTransport.CreateInputParameterXML("Dose", trnDataTypeFloat, 4, PCTClaim.dose)
         strParams = strParams & gTransport.CreateInputParameterXML("DailyDose", trnDataTypeFloat, 4, PCTClaim.dailydose)
         If PCTClaim.PCTPatientCategory = "W" Then  '15Sep15 XN 51497 set extra fields to null is wastage
             strParams = strParams & gTransport.CreateInputParameterXML("PrescriptionFlag", trnDataTypeBit, 1, Null)
         Else
             strParams = strParams & gTransport.CreateInputParameterXML("PrescriptionFlag", trnDataTypeBit, 1, PCTClaim.PrescriptionFlag)
         End If
         strParams = strParams & gTransport.CreateInputParameterXML("DoseFlag", trnDataTypeBit, 1, PCTClaim.DoseFlag)
         'strParams = strParams & gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription)  '09Jan12 TH Replaced with below
         strParams = strParams & gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeVarChar, 9, Trim$(PCTClaim.PrescriptionID))
         strParams = strParams & gTransport.CreateInputParameterXML("ServiceDate", trnDataTypeDateTime, 8, PCTClaim.ServiceDate)
         strParams = strParams & gTransport.CreateInputParameterXML("ClaimCode", trnDataTypeint, 4, PCTClaim.ClaimCode)
         strParams = strParams & gTransport.CreateInputParameterXML("QuantityClaimed", trnDataTypeFloat, 4, PCTClaim.QuantityClaimed)
         strParams = strParams & gTransport.CreateInputParameterXML("PackUnitOfMeasure", trnDataTypeVarChar, 8, Trim$(PCTClaim.PackUnitOfMeasure))
         strParams = strParams & gTransport.CreateInputParameterXML("ClaimAmount", trnDataTypeFloat, 4, PCTClaim.ClaimAmount)
         strParams = strParams & gTransport.CreateInputParameterXML("CBSSubsidy", trnDataTypeFloat, 1, PCTClaim.CBSSubsidy)
         strParams = strParams & gTransport.CreateInputParameterXML("CBSPacksize", trnDataTypeFloat, 4, PCTClaim.CBSPacksize)
         strParams = strParams & gTransport.CreateInputParameterXML("Funder", trnDataTypeVarChar, 3, Trim$(PCTClaim.Funder))
         If PCTClaim.PCTPatientCategory = "W" Then
            strParams = strParams & gTransport.CreateInputParameterXML("FormNumber", trnDataTypeVarChar, 4, Null)
         Else
            strParams = strParams & gTransport.CreateInputParameterXML("FormNumber", trnDataTypeVarChar, 9, Trim$(Format$(PCTClaim.FormNumber)))
         End If
         strParams = strParams & gTransport.CreateInputParameterXML("PCTTransactionStatusID", trnDataTypeint, 4, "3")
         strParams = strParams & gTransport.CreateInputParameterXML("ParentID", trnDataTypeint, 4, Null)
         strParams = strParams & gTransport.CreateInputParameterXML("SupersededDate", trnDataTypeDateTime, 8, Null)
         strParams = strParams & gTransport.CreateInputParameterXML("SupersededByEntityID", trnDataTypeint, 4, Null)
         strParams = strParams & gTransport.CreateInputParameterXML("ScheduleDate", trnDataTypeDateTime, 4, PCTClaim.ScheduleDate)
         '09Jan12 TH Added
         strParams = strParams & gTransport.CreateInputParameterXML("PrescriptionSuffix", trnDataTypeVarChar, 2, "0")
         strParams = strParams & gTransport.CreateInputParameterXML("RequestID_Prescription", trnDataTypeint, 4, gRequestID_Prescription)
         strParams = strParams & gTransport.CreateInputParameterXML("RequestID_Dispensing", trnDataTypeint, 4, L.RequestID)
         
         GetPointerSQL rootpath$ & "\PCTTrans", lngPCTTransaction, True
         strParams = strParams & gTransport.CreateInputParameterXML("UniqueTransactionNumber", trnDataTypeint, 4, lngPCTTransaction)
         '-------------
         
         WriteLog dispdata$ & "\RECOVER.PCT", 0, "", strParams
         
        'lngOK = gTransport.ExecuteInsertSP(g_SessionID, "PCTClaimTransaction", strParams)
        lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPCTClaimTransactionInsertfromDispensing", strParams)
        '(g_SessionID, "PBSTransactionInsert", SQL$, 0, "")
         
         '11Apr08 TH Added some basic error trapping around the return from the Billing Component
         'If InStr(LCase(strPBSDrugRepeat), "<pbsTransaction>") = 0 Then
         'If Len(strPBSDrugRepeat) > 100 Then
         If lngOK < 1 Then
            WriteLog dispdata$ & "\TransErr.PCT", 0, "", strParams
            popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: LogTransaction" & cr & cr & "Failed to log transaction. This may affect the PCT Claim." & cr & cr & "Refer to " & Trim$(dispdata$) & "\TransError.PCT for details"
         End If
         'NEED Error handling here !!!!!!!!
      
LogPCTClaimTransactionExit:
   On Error GoTo 0
   Exit Sub

LogPCTClaimTransactionErr:
   popmessagecr ".Patient Billing", "An error has occurred in the program" & cr & cr & "Procedure: LogTransaction" & cr & "Error: " & Error$ & cr & "Error number: " & Err & cr & cr & "Failed to log transaction"
   Resume LogPCTClaimTransactionExit

End Sub

Function IsPCTDispensing()
'Return whether we are PCT enabled or not

   IsPCTDispensing = m_blnPCTDispensing

End Function

Sub LoadPCTPrimaryIngredient(ByVal lngProductStockID As Long)
'THis sub should take in a productstock row and find and load (if possible) any linked Primary PCTProduct
'If no Primary product can be found we swith off PCT using the "big PCT dispensing switch".

Dim strParams As String
Dim rsPCTProduct As ADODB.Recordset


   strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, lngProductStockID) _
      & gTransport.CreateInputParameterXML("Primary", trnDataTypeBit, 1, 1)
   
   Set rsPCTProduct = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductbyProductstockIDandPrimary", strParams)
   If Not rsPCTProduct.EOF Then
      rsPCTProduct.MoveFirst
      'Should only be one row so lets load here
      m_PCTProduct.Alternate = RtrimGetField(rsPCTProduct!Alternate)
      m_PCTProduct.BrandCode = RtrimGetField(rsPCTProduct!BrandCode)
      m_PCTProduct.BrandName = RtrimGetField(rsPCTProduct!BrandName)
      m_PCTProduct.CBS = RtrimGetField(rsPCTProduct!CBS)
      m_PCTProduct.ChemicalName = RtrimGetField(rsPCTProduct!ChemicalName)
      m_PCTProduct.FormulationName = RtrimGetField(rsPCTProduct!FormulationName)
      m_PCTProduct.Multiple = RtrimGetField(rsPCTProduct!Multiple)
      m_PCTProduct.OP = RtrimGetField(rsPCTProduct!OP)
      m_PCTProduct.PCTMasterProductID = RtrimGetField(rsPCTProduct!PCTMasterProductID)
      m_PCTProduct.Pharmacode = RtrimGetField(rsPCTProduct!Pharmacode)
      m_PCTProduct.Price = RtrimGetField(rsPCTProduct!Price)
      m_PCTProduct.quantity = RtrimGetField(rsPCTProduct!quantity)
      m_PCTProduct.SpecialEndorsementType = RtrimGetField(rsPCTProduct!SpecialEndorsementType)
      m_PCTProduct.SpecialType = RtrimGetField(rsPCTProduct!SpecialType)
      m_PCTProduct.Specified = RtrimGetField(rsPCTProduct!Specified)
      m_PCTProduct.Subsidy = RtrimGetField(rsPCTProduct!Subsidy)
      m_PCTProduct.Units = RtrimGetField(rsPCTProduct!Units)
      m_PCTProduct.ScheduleDate = RtrimGetField(rsPCTProduct!DrugFileDate)
   Else
      popmessagecr "", "This item is not linked to any PCT Ingredients." & crlf & "Issue will continue as normal, but no PCT Claim will be posted"
      m_blnPCTDispensing = False
   End If
   rsPCTProduct.Close
   Set rsPCTProduct = Nothing
   
   


End Sub
Sub LogAllPCTDispensings()
'05Dec11 TH Written.
'This is the main wrapper for the PCT Claim lodging.
'This is called when we have a PCT claim to do and have commited the issue
'THerefore we should have no UI. This should merely record all PCT claims require, either;

'A) Wastage Only Primary and secodary ingredients
'B) Claim line plus possible partial wastage for primarhy and secondary ingredients.

'Use a PCTClaim type to assemble the data here and call the IO with this.

Dim intIngLoop As Integer
Dim lngYears As Long

   'fill out the rx stable parts of the claim (this may be less for WASTAGE !
   m_PCTClaimTransaction.Category = "P"
   m_PCTClaimTransaction.CBSPacksize = 0
   m_PCTClaimTransaction.CBSSubsidy = 0
   m_PCTClaimTransaction.ClaimCode = m_PCTProduct.Pharmacode
   m_PCTClaimTransaction.ScheduleDate = m_PCTProduct.ScheduleDate
   If m_PCTPatient.PHORegistered Then
      m_PCTClaimTransaction.CSCorPHOStatusFlag = "Q"
   ElseIf m_PCTPatient.CSC Then
      m_PCTClaimTransaction.CSCorPHOStatusFlag = "Y"
   Else
      m_PCTClaimTransaction.CSCorPHOStatusFlag = "N"
   End If
   'm_PCTClaimTransaction.CSCorPHOStatusFlag = IIf(m_PCTPatient.CSC Or m_PCTPatient.PHORegistered, True, False)
   m_PCTClaimTransaction.EndorsementDate = m_PCTPrescription.EndorsementDate
   m_PCTClaimTransaction.FormNumber = m_PCTPrescription.PrescriptionFormNumber
   m_PCTClaimTransaction.Funder = TxtD(dispdata$ & "\patbill.ini", "PCT", "DHB", "Funder", 0)
   m_PCTClaimTransaction.HealthProfessionalGroupCode = TxtD(dispdata$ & "\patbill.ini", "PCT", "MC", "HealthProfessionalGroupCode", 0)
   If Trim$(m_PCTPatient.HUHCNo) <> "" Then
      m_PCTClaimTransaction.HUHCStatusFlag = True
   Else
      m_PCTClaimTransaction.HUHCStatusFlag = False
   End If
   m_PCTClaimTransaction.NHI = m_PCTPatient.NHINumber
   m_PCTClaimTransaction.PackUnitOfMeasure = m_PCTProduct.Units
   m_PCTClaimTransaction.PCTOncologyPatientGroupingCode = m_PCTPrescription.PCTOncologyPatientGroupingCode
   
   'm_PCTClaimTransaction.PCTPatientCategory = m_PCTPatient.
   If m_PCTPatient.PermResHokianga Then
      m_PCTClaimTransaction.PCTPatientCategory = "H"
   Else
      'Need to do an age cal on this
      lngYears = DateDiff("yyyy", m_PCTPatient.dob, Now)
      If lngYears < 6 Then
         m_PCTClaimTransaction.PCTPatientCategory = "Y"
      ElseIf lngYears < 18 Then
         m_PCTClaimTransaction.PCTPatientCategory = "J"
      ElseIf lngYears > 64 And TrueFalse(TxtD(dispdata$ & "\patbill.ini", "PCT", "N", "PatientCatgorySeniorCheck", 0)) Then
         m_PCTClaimTransaction.PCTPatientCategory = "S"
      Else
         m_PCTClaimTransaction.PCTPatientCategory = "A"
      End If
   End If
   m_PCTClaimTransaction.PrescriberFlag = "N"
   If Trim$(m_PCTPrescription.SpecialistEndorserNZMCNumber) <> "" Then
      m_PCTClaimTransaction.PrescriptionFlag = True ' "Y" '15Dec11 TH was true
   Else
      m_PCTClaimTransaction.PrescriptionFlag = False '"N" '15Dec11 TH was false
   End If
   m_PCTClaimTransaction.PrescriberID = m_PCTPrescription.PrescriberNZMCNumber
   m_PCTClaimTransaction.SpecialAuthorityNumber = m_PCTPrescription.SpecialAuthorityNumber
   m_PCTClaimTransaction.SpecialistID = m_PCTPrescription.SpecialistEndorserNZMCNumber
   m_PCTClaimTransaction.ServiceDate = Now
   
   'If not wastage then we do active claims first
   If Not m_PCTPrescription.fullWastage Then
   
      For intIngLoop = 1 To m_intIngredients
         If m_PCTIngredients(intIngLoop).Qty > 0 Then
            'Cost of item                     =  (Pharmacy subsidy for pack / ascribe packsize/dose per issue unit) * total dosing units
             'm_PCTClaimTransaction.ClaimAmount = ((m_PCTProduct.Subsidy / d.convfact / d.dosesperissueunit) * m_PCTIngredients(intIngLoop).Qty) * VAT(d.vatrate) '
             '27Feb12 TH Replaced after BL testing
             'm_PCTClaimTransaction.ClaimAmount = (((m_PCTProduct.Subsidy * 100) / d.convfact / d.dosesperissueunit) * m_PCTIngredients(intIngLoop).Qty) * VAT(d.vatrate) '04Jan12 TH Subsidy in dollars
             m_PCTClaimTransaction.ClaimAmount = (((m_PCTProduct.Subsidy * 100) / m_PCTProduct.quantity) * m_PCTIngredients(intIngLoop).Qty) * VAT(d.vatrate) '04Jan12 TH Subsidy in dollars
             
             m_PCTClaimTransaction.dailydose = m_PCTIngredients(intIngLoop).dailydose
             m_PCTClaimTransaction.dose = m_PCTIngredients(intIngLoop).dose
             If (m_PCTIngredients(intIngLoop).dose <> 0) And (m_PCTClaimTransaction.dailydose <> 0) Then
               m_PCTClaimTransaction.DoseFlag = False
             Else
               m_PCTClaimTransaction.DoseFlag = True
            End If
            m_PCTClaimTransaction.QuantityClaimed = m_PCTIngredients(intIngLoop).Qty
            m_PCTClaimTransaction.ClaimCode = m_PCTIngredients(intIngLoop).Pharmacode
            'm_PCTClaimTransaction.PrescriptionID = Val(Left$(Format$(L.PrescriptionID) & "0000000", 8) & Format$(intIngLoop))
            m_PCTClaimTransaction.PrescriptionID = Format$(intIngLoop) & Right$("0000000" & Format$(L.PrescriptionID), 8) '12Jan12 TH This should allow full use of figs and prevent dupes.
            LogPCTClaimTransaction m_PCTClaimTransaction
         End If
      Next
   End If
   
   'Now we do wastage claims
   For intIngLoop = 1 To m_intIngredients
      If m_PCTIngredients(intIngLoop).WastageQty > 0 Then
         m_PCTClaimTransaction.ClaimCode = m_PCTIngredients(intIngLoop).Pharmacode
         'Cost of item                     =  (Pharmacy subsidy for pack / ascribe packsize/dose per issue unit) * total dosing units
         'm_PCTClaimTransaction.ClaimAmount = ((m_PCTProduct.Subsidy / d.convfact / d.dosesperissueunit) * m_PCTIngredients(intIngLoop).WastageQty) * VAT(d.vatrate)
         '27Feb12 TH Replaced after BL testing
         'm_PCTClaimTransaction.ClaimAmount = (((m_PCTProduct.Subsidy * 100) / d.convfact / d.dosesperissueunit) * m_PCTIngredients(intIngLoop).WastageQty) * VAT(d.vatrate) '04Jan12 TH Subsidy in dollars
         m_PCTClaimTransaction.ClaimAmount = (((m_PCTProduct.Subsidy * 100) / m_PCTProduct.quantity) * m_PCTIngredients(intIngLoop).WastageQty) * VAT(d.vatrate)
         m_PCTClaimTransaction.dailydose = m_PCTIngredients(intIngLoop).dailydose
         m_PCTClaimTransaction.dose = m_PCTIngredients(intIngLoop).dose
         If (m_PCTIngredients(intIngLoop).dose <> 0) And (m_PCTClaimTransaction.dailydose <> 0) Then
            m_PCTClaimTransaction.DoseFlag = False
         Else
            m_PCTClaimTransaction.DoseFlag = True
         End If
         'm_PCTClaimTransaction.QuantityClaimed = m_PCTIngredients(intIngLoop).Qty
         m_PCTClaimTransaction.QuantityClaimed = m_PCTIngredients(intIngLoop).WastageQty   '04Jan12 TH THese are wastage claims -we claim for wastage
          
         'Set Anything just for wastage - No send nulls in IO Layer
         m_PCTClaimTransaction.SpecialistID = ""
         m_PCTClaimTransaction.NHI = ""
         m_PCTClaimTransaction.PCTPatientCategory = "W"
         m_PCTClaimTransaction.CSCorPHOStatusFlag = "N"
         m_PCTClaimTransaction.SpecialAuthorityNumber = ""
         m_PCTClaimTransaction.dose = 0
         m_PCTClaimTransaction.dailydose = 0
         m_PCTClaimTransaction.DoseFlag = True
         'm_PCTClaimTransaction.FormNumber = ""
         
         'm_PCTClaimTransaction.EndorsementDate = Null
         'm_PCTClaimTransaction.PrescriberFlag = Null
         'm_PCTClaimTransaction.PCTOncologyPatientGroupingCode = Null
          
          
         'm_PCTClaimTransaction.HUHCStatusFlag = Null
         m_PCTClaimTransaction.PrescriptionID = ""
          
         LogPCTClaimTransaction m_PCTClaimTransaction
      End If
   Next

End Sub
Sub setPCTPRNflag(ByVal blnPRN As Boolean)
   m_blnPCTPRN = blnPRN
End Sub
Function getPCTPRNflag() As Boolean
   getPCTPRNflag = m_blnPCTPRN
End Function

Sub setPCTNoCourseLengthFlag(ByVal blnNoCourseLength As Boolean)
   m_blnPCTNoCourseLength = blnNoCourseLength
End Sub
Function getPCTNoCourseLengthflag() As Boolean
   getPCTNoCourseLengthflag = m_blnPCTNoCourseLength
End Function
Sub setPCTStatflag(ByVal blnStat As Boolean)
   m_blnPCTStat = blnStat
End Sub
Function getPCTStatflag() As Boolean
   getPCTStatflag = m_blnPCTStat
End Function
Sub setPCTCourseLength(ByVal intDays As Integer)
   m_intCourseDays = intDays
End Sub
Function PCTCheckForRepeat() As Boolean

'10Jan12 TH Now we need to check the PCT history to stop repeats
Dim strParams As String
Dim rsPCTRepeat As ADODB.Recordset

      PCTCheckForRepeat = False
      strParams = gTransport.CreateInputParameterXML("PrescriptionID", trnDataTypeint, 4, gRequestID_Prescription)
      Set rsPCTRepeat = gTransport.ExecuteSelectSP(g_SessionID, "pPCTClaimTransactionByRequestID_Prescription", strParams)
      
      If Not rsPCTRepeat.EOF Then
         'We have a record so we must switch of pct - tell the user and leave
         PCTCheckForRepeat = True
      End If
      rsPCTRepeat.Close
      Set rsPCTRepeat = Nothing
      
End Function
Sub SetPCTDispensing(ByVal blnPCTDispensung As Boolean)
'Set whether we are PCT enabled or not

   m_blnPCTDispensing = blnPCTDispensung
   
End Sub

