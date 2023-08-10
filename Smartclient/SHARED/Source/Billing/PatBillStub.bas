Attribute VB_Name = "PatBillStub"
'Patient Billing Module Stub

'This is being used to store some limited functionality now for DoC as an interim
'until true PBS can be re-integrated

'18Aug13 TH BillPatient :Added in stuff DoC Pending Full PBS
'                        Label element Handling (1)
'                        Qty Handling (rpt override) (9)

'21Aug13 TH BillPatient :(TFS 71678) Set default UseRepeatQty to "Y"
'23Aug13 TH BillPatient :Set UseBatchnumberforRepeats default to "N"

'19Sep13 TH PBSDrugToDispens: Now need to handle this for DoC when we have a repeat qty
'  "                          Formerly this would always return false (TFS 73735)

DefInt A-Z
Option Explicit

'02Nov07 TH Addded for the PCT Workaround.

Type PrescriberStruct
   LegacyCode As String * 5
   inuse As Integer
   name As String * 30
   Address1 As String * 30
   Address2 As String * 30
   Address3 As String * 30
   postCode As String * 10
   telephonenumber As String * 20
   'specialist As String * 25
   'secondaryCode As String * 15
   'registrationNumber As String * 15
   'datecreated As Date
   prescribertype As String * 2
   NZMCNumber As String * 10
   freetext As String
   Prescriber_EntityID As Long
End Type

Dim m_Prescriber As PrescriberStruct
Dim m_strBillingComponentURL As String

Function billpatient(Action%, txtReturn$) As Variant
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

'18Aug13 TH Added in stuff DoC Pending Full PBS
'           Label element Handling (1)
'           Qty Handling (rpt override) (9)

'21Aug13 TH (TFS 71678) Set default UseRepeatQty to "Y"
'23Aug13 TH Set UseBatchnumberforRepeats default to "N"

Dim repeatsAllowed%, txt$, repeatByDate$
Dim blnNoRpts As Boolean


   If Action = 1 Then
      'repeatsAllowed% = NumberOfRepeats%()
      repeatsAllowed% = getTotalRepeats()
      If repeatsAllowed% = 0 Then blnNoRpts = True
      'If TrueFalse(TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "N", "RepeatsOnly", 0)) Then
      If TrueFalse(TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "N", "RepeatsOnly", 0)) Then '23Sep13 TH (TFS 73946)
         repeatsAllowed% = repeatsAllowed% + 1
      End If
      
      'If TrueFalse(TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then
      If TrueFalse(TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "N", "UseBatchnumberforRepeats", 0)) Then '23Sep13 TH (TFS 73946)
         If (repeatsAllowed%) = L.batchnumber Or L.batchnumber = 0 Then
            'txt$ = TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "", "LastRepeatText", 0)
            txt$ = TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "", "LastRepeatText", 0) '23Sep13 TH (TFS 73946)
            'If qtyOwed! > 0 Then txt$ = txt$ & " but owed " & Format$(toOwe!) & Trim$(d.PrintformV)
            Heap 10, gPRNheapID, "pbRepeatText", txt$, 0
         Else
            'DT1.mint = L.StopDate
            'minstodate DT1
            'DateToString DT1, repeatByDate$
            repeatByDate$ = getRptPrescriptionExpiry()
   
            'txt$ = TxtD(dispdata$ & "D|Patbill.ini", "PatientBilling", "", "RepeatText", 0)
            txt$ = TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "", "RepeatText", 0) '23Sep13 TH (TFS 73946)
            txt$ = txt$ & Format$((repeatsAllowed%) - L.batchnumber) & " repeat(s) before "
            txt$ = txt$ & repeatByDate$
            'If qtyOwed! > 0 Then txt$ = txt$ & " and owed " & Format$(toOwe!) & Trim$(d.PrintformV)
         End If
         Heap 10, gPRNheapID, "pbRXNo", Format$(L.PrescriptionID) & "/" & Format$(L.batchnumber), 0
      Else
         'here we need the repeat count coming in from the repeat rx link row
         If (repeatsAllowed%) = getRepeatNumber() Or getRepeatNumber() = 0 Then
            txt$ = TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "", "LastRepeatText", 0)
            'If qtyOwed! > 0 Then txt$ = txt$ & " but owed " & Format$(toOwe!) & Trim$(d.PrintformV)
            Heap 10, gPRNheapID, "pbRepeatText", txt$, 0
         Else
            'DT1.mint = L.StopDate
            'minstodate DT1
            'DateToString DT1, repeatByDate$
            repeatByDate$ = getRptPrescriptionExpiry
   
            txt$ = TxtD(dispdata$ & "\Patbill.ini", "PatientBilling", "", "RepeatText", 0)
            txt$ = txt$ & Format$((repeatsAllowed%) - getRepeatNumber()) & " repeat(s) before "
            txt$ = txt$ & repeatByDate$
            'If qtyOwed! > 0 Then txt$ = txt$ & " and owed " & Format$(toOwe!) & Trim$(d.PrintformV)
         End If
         Heap 10, gPRNheapID, "pbRXNo", Format$(L.PrescriptionID) & "/" & Format$(getRepeatNumber()), 0
      End If
      
      If blnNoRpts Then txt$ = ""
      Heap 10, gPRNheapID, "pbRepeatText", txt$, 0
   ElseIf Action = 9 Then
      'Are We using MOJ Style Repeat Qtys ? and do we have such a Qty
      'If so we can substitute this for the calculated qty on the script
      If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "RepeatCycles", "Y", "UseRepeatQty", 0)) Then '21Aug13 TH (TFS 71678) Set default UseRepeatQty to "Y"
         If getRptQuantity() > 0 Then
            FrmIssue.Caption = Trim$(FrmIssue.Caption) & TxtD(dispdata$ & "\RptDisp.ini", "RepeatCycles", " (Repeat Qty)", "RepeatQtyIssueCaption", 0)
            'txtReturn$ = Format$(m_PBSProduct.maxqty)
            FrmIssue.TxtIssue.text = Format$(getRptQuantity())
            Qty! = getRptQuantity()
         End If
      End If
   End If
   billpatient = False
End Function

Function CheckPBSIssue() As Integer
   CheckPBSIssue = False
End Function

Sub DoPatientBilling(tmwrkfunction As Integer, ASCbutton As Integer)
End Sub

Function isPBS() As Integer
   isPBS = False
End Function

Sub ItemTypeStatus(writeIt%, PBSOriginalRxDate$, strPBSAuthorityNum As String, strPBSOriginalApprovalnum As String)
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
End Sub

Sub PatBilling_Callback(Index%)
End Sub

Function PBSDrugToDispens() As Boolean
'19Sep13 TH Now need to handle this for DoC when we have a repeat qty
'  "        Formerly this would always return false (TFS 73735)


Dim blnResult As Boolean

   blnResult = False
   
   If TrueFalse(TxtD(dispdata$ & "\RptDisp.ini", "RepeatCycles", "Y", "UseRepeatQty", 0)) Then '21Aug13 TH (TFS 71678) Set default UseRepeatQty to "Y"
      If getRptQuantity() > 0 Then blnResult = True
   End If
         
   PBSDrugToDispens = blnResult
End Function

Function PBSGetBillitem(intIndex As Integer) As String
End Function


Function PBSGetExceptionalQty() As Integer
End Function

Function PBSGetFoundDrugItem() As Integer
End Function

Function PBSIsScreenBigEnough() As Integer
   PBSIsScreenBigEnough = False
   If Screen.Width >= 12000 And (Screen.TwipsPerPixelY * 600 < Screen.Height) Then PBSIsScreenBigEnough = True
End Function

Function PBSKeepDate()
   PBSKeepDate = False  ''**!!** may need to be revised
End Function

Sub PBSPatientLoad()
End Sub

Sub PBSPatInfoDisplay(ctlDisplay As Control)
End Sub

Sub PBSPreIssueChecks(blnPassed As Integer)
End Sub

Function PBSReadBillitem(intBillitem As Integer) As String
   PBSReadBillitem = "N"
End Function

Sub PBSRefreshPatDetails(ctlDisplay As Control)
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

Sub Rx_Callback(Index%)
End Sub
Sub Supplier_Callback(Index%)
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

Sub setQuesdefaults(blnKeepStatus As Integer)
End Sub

Function BillPatDispensQty%(stockLevel!, DispensQty!, negorpos%, escd%)
End Function

Function PrivateBilling() As Integer
End Function


Sub SetUpPCTWorkaround(ByVal RequestID_Prescription As Long)
'02Nov07 TH PCT Workaround entry point
'Here we are given the requestID,
'The process ;
'Check the repeat table for the PrescriberID
'If no PrescriberID then Load the PrescriberID from State
'and Record the Prescriber ID in the Repeat table

'If we have a prescriber we store the legacy code in the existing Global
'This will be used in the Transaction
Dim strXML As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMNode
Dim PCTPrescriberID As Long
Dim blnWriteRepeat As Boolean
Dim strParams As String
Dim strPCTRepeat As String
Dim PCTRepeatID As Long

   PCTPrescriberID = 0 'set variable
   'Blank the Prescriber type
   m_Prescriber.LegacyCode = ""
   m_Prescriber.name = ""
   m_Prescriber.NZMCNumber = ""
   m_Prescriber.Prescriber_EntityID = 0
   m_Prescriber.prescribertype = ""
   '----------------
   
   'First we will set the URL for the billing component
   m_strBillingComponentURL = TxtD$(dispdata & "\" & "patmed.ini", "PatientBilling", "", "BillingComponentURL", 0)
   
   If Trim$(m_strBillingComponentURL) = "" Then
      popmessagecr ".Patient Billing", "Billing component setting missing. Prescriber details will not be recorded in PCT Claim"
      Exit Sub
   End If
   

   'Now we check the repeat table
   strXML = BillingInterface(g_SessionID, "GetPCTRepeatbyRequestID", "", RequestID_Prescription)
   If InStr(LCase(strXML), "pctrepeat") > 0 Then 'And (Not m_blnPBSNewScript
      Set xmldoc = New MSXML2.DOMDocument
      If xmldoc.loadXML(strXML) Then
         Set xmlnode = xmldoc.selectSingleNode("xml/PCTRepeat")
         On Error Resume Next
         PCTPrescriberID = Val(xmlnode.Attributes.getNamedItem("PCTPrescriberID").text)
         On Error GoTo 0
         Set xmlnode = Nothing
      End If
   End If
   If PCTPrescriberID > 0 Then
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PCTDebug", 0)) Then WriteLog "c:\pctdebug.log", 1, "PCTDEBUG", "REPEAT DETECTED"  'PBSDEBUG
      strXML = BillingInterface(g_SessionID, "GetPCTPrescriber", "", PCTPrescriberID)
      strXML = LCase$(strXML)
   Else
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "N", "PCTDebug", 0)) Then WriteLog "c:\pctdebug.log", 1, "PCTDEBUG", "NO REPEAT DETECTED - GOING TO STATE"  'PBSDEBUG
      strXML = BillingInterface(g_SessionID, "GetPCTPrescriberfromState", "PCTPrescriberID_EntityID", 0)
      blnWriteRepeat = True
   End If
   'Read the Prescriber from the xml and update the globals
   If InStr(LCase(strXML), "pctprescribercode") > 0 Then
      Set xmldoc = New MSXML2.DOMDocument
      If xmldoc.loadXML(strXML) Then
         Set xmlnode = xmldoc.selectSingleNode("xml/pctprescriber")
         m_Prescriber.NZMCNumber = xmlnode.Attributes.getNamedItem("pctprescribercode").text
         m_Prescriber.prescribertype = xmlnode.Attributes.getNamedItem("pctprescribertypecode").text
         'gPrescriberID$ = Val(xmlnode.Attributes.getNamedItem("entityid").Text)
         m_Prescriber.inuse = True
         m_Prescriber.name = xmlnode.Attributes.getNamedItem("forename").text & " " & xmlnode.Attributes.getNamedItem("surname").text
         m_Prescriber.LegacyCode = xmlnode.Attributes.getNamedItem("pctlegacycode").text
         gPrescriberID$ = m_Prescriber.LegacyCode
         m_Prescriber.Prescriber_EntityID = xmlnode.Attributes.getNamedItem("entityid").text
         Set xmlnode = Nothing
      Else
         If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "Y", "PCTWorkaroundmsg", 0)) Then popmessagecr ".Patient Billing", "Could not load prescriber information. Prescriber details will not be recorded in PCT Claim"
         blnWriteRepeat = False
      End If
      Set xmldoc = Nothing
   Else
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "Y", "PCTWorkaroundmsg", 0)) Then popmessagecr ".Patient Billing", "No current prescriber available. Prescriber details will not be recorded in PCT Claim"
      blnWriteRepeat = False
   End If
   
   'If blnWriteRepeat And m_Prescriber.LegacyCode <> "" Then        '13Nov07 TH Replaced
   If blnWriteRepeat And m_Prescriber.Prescriber_EntityID > 0 Then
      strParams = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID_Prescription) & _
                  gTransport.CreateInputParameterXML("PCTPrescriberID", trnDataTypeint, 4, m_Prescriber.Prescriber_EntityID)
   'If m_PBSDrugRepeat.NumberOfRepeats <> -1 Then  'Update
   'Nov07 TH Aways assume insert
   'If m_PBSDrugRepeat.PBSDrugRepeatID > 0 Then
   '   strParams = gTransport.CreateInputParameterXML("PBSDrugRepeatID", trnDataTypeint, 4, m_PBSDrugRepeat.PBSDrugRepeatID) & strParams
   '   strPBSDrugRepeat = BillingInterface(g_SessionID, "PBSDrugRepeatUpdate", strParams, 0)
   'Else 'Insert
      strPCTRepeat = BillingInterface(g_SessionID, "PCTRepeatInsert", strParams, 0) & Space$(6)
      PCTRepeatID = Val(Mid$(strPCTRepeat, 6)) '15May07 TH Added
      If PCTRepeatID < 1 Then
            If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "PatientBilling", "Y", "PCTWorkaroundmsg", 0)) Then popmessagecr ".Patient Billing", "Could not save repeat record. Prescriber details will not be recorded in PCT Claim for subsequent dispensings of this script"
      End If
   End If
   

End Sub

Function BillingInterface(ByVal sessionID As Long, ByVal strMethod As String, ByVal strParams As String, ByVal DataID As Long) As String
'03May07 TH Written as nice wrapper for the billing component
Dim HttpRequest As WinHttpRequest
Dim strPost As String
Dim strXML As String


'm_strBillingComponentURL = "http://localhost/PBST/default.aspx"

strXML = ""
strPost = "txtMethod=" & strMethod & "&txtSessionID=" & Format$(sessionID) & "&txtEntityID=" & Format(DataID) & "&txtDataID=" & Format(DataID) & "&txtDATA=" & strParams & "&txtSiteID=" & Format(gDispSite)

   Set HttpRequest = New WinHttpRequest
   HttpRequest.open "POST", m_strBillingComponentURL, False
   HttpRequest.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
   HttpRequest.send (strPost)
   strXML = HttpRequest.responseText
   Set HttpRequest = Nothing
   strXML = "<xml>" & strXML & "</xml>"

BillingInterface = strXML

End Function
Function getPrescriberID() As Long
'07Nov07 TH Written

   getPrescriberID = m_Prescriber.Prescriber_EntityID

End Function
