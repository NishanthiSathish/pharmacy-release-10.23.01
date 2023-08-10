Attribute VB_Name = "PSO"

'06Aug12 TH Written to suppport Patient Specific Ordering

'08Aug12 TH SelectPSOSupProfile: Written based on old Supplier profile selsect (TFS 40712)
'10Aug12 TH SelectPSOSupProfile: (TFS 41012) Ensure the default is top of the list
'15Aug12 TH CreatePSOrder: Altered table to key on Label NOT Order (as Order may become 1:Many on Partial Receipt/Invoice etc.) (TFS 40931)(TFS 40713) (TFS 40789)
'09Nov12 TH SelectPSOSupProfile: Removed check on Supplier validity - in terms of user warning (TFS 48649)
'13Nov12 TH CreatePSOrder: enhanced special message inout box (TFS 48650)
'11Mar13 TH SelectPSOSupProfile: mods to fix supplier selection  (TFS 58631)
'13Dec15 TH CreatePSOrder: Removed New patient from none Hub order (Hub and None Hub should be aligned) (TFS 138047)



DefInt A-Z
Option Explicit

Dim m_PSOSupplier As supplierstruct

Private Const OBJNAME As String = PROJECT & "PSO."


Public Function SelectPSOSupProfile() As Boolean
'08Aug12 TH Written based on old Supplier profile selsect (TFS 40712)
'10Aug12 TH (TFS 41012) Ensure the default is top of the list
'09Nov12 TH Removed check on Supplier validity - in terms of user warning (TFS 48649)
'11Mar13 TH mods to fix supplier selection  (TFS 58631)
'25Aug14 TH Added new validation checking
'17Nov14 TH Added drug details to msg or menu header (TFS 79767)

Dim Numoflines%, i%, FoundSup As Long, success%, NumOfEntries%, found%, View%
Dim SupProfile As TSupProfile
Dim ans$, txt$, Selected$
Dim seperator$                                  '06Jan00 AW added
Dim Vatview%
Dim invalidaltsup%        '25Jan00 TH
Dim strAltSups As String
Dim intAddNew As Integer
Dim blnAddNew As Boolean
Dim strSupCode As String
Dim strAns As String
Dim intSuppliers As Integer
Dim strDesc As String

   ReDim Menu$(10), menuhlp%(10), supcode$(10), PSOSupCode(10) As String
   
   clearsup m_PSOSupplier

   'Display list of suppliers for this drug
   'Menu$(0) = "Select Patient Specific Order Supplier"
   '17Nov14 TH Added drug details to header (TFS 79767)
   'strDesc = Trim$(d.storesdescription)
   'If Trim$(strDesc) = "" Then strDesc = Trim$(d.Description) XN 4Jun15 98073 New local stores description
   strDesc = Trim$(d.DrugDescription)
   plingparse strDesc, "!"
   strDesc = d.SisCode & "   " & strDesc
         
   Menu$(0) = "Select Patient Specific Order Supplier for " & crlf & crlf & strDesc & crlf

   'Add Primary supplier..
   getsupplier d.supcode, 0, FoundSup, sup
   If FoundSup Then                   '20Mar01 TH Added Check to ensure default supplier is valid
      'Menu$(1) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"

      'Add alternative supplier codes
      'seperator$ = " " '11Mar13 TH Replaced with below (TFS 58631)
      seperator$ = ","
      strAltSups = GetAltenativeSupplierString(d.SisCode)
      '10Aug12 TH (TFS 41012) OK - a bit of hokum required to ensure the default is top of the list
      'replace strAltSups, d.supcode, "", 0
      replace strAltSups, Trim$(d.supcode), "", 0
      'strAltSups = d.supcode & "," & strAltSups  '11Mar13 TH Replaced with below (TFS 58631)
      strAltSups = Trim$(d.supcode) & "," & strAltSups
      replace strAltSups, ",,", ",", 0
      
      deflines strAltSups, supcode$(), seperator$, 1, Numoflines% '22Jan07 TH Replaced
      '11Mar13 TH Removed. Now only use comma as seperator (TFS 58631)
      'If Numoflines <= 1 Then                                                   '         "
      '   seperator$ = ","                                                    '         "
      '   deflines strAltSups, supcode$(), seperator$, 1, Numoflines%       '         "
      'End If
      
      intSuppliers = 0
      If Numoflines >= 1 Then
         For i% = 1 To Numoflines%
            getsupplier supcode$(i), 0, FoundSup, sup
            If FoundSup Then
               If UCase(Trim(d.supcode)) = UCase(Trim(sup.Code)) Then
                  If sup.PSO Then
                     intSuppliers = intSuppliers + 1
                     Menu$(intSuppliers) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"
                     PSOSupCode(intSuppliers) = sup.Code
                  End If
               Else
                  If sup.PSO Then
                     intSuppliers = intSuppliers + 1
                     Menu$(intSuppliers) = sup.Code & TB & TB & sup.name
                     PSOSupCode(intSuppliers) = sup.Code
                  End If
               End If
            'Else                                                                                   '20Mar01 TH Added '09Nov12 TH Removed (TFS 48649)
            '   popmessagecr "", "Alternative Supplier " & supcode$(i) & " is not a valid supplier" '    "            '    "
            End If
         Next
      End If
      If intSuppliers > 1 Then
         inputmenu Menu$(), menuhlp%(), ans$, k
         If Not k.escd Then
            If Val(ans$) > 0 Then                                               '20Mar01 TH Added
               'getsupplier PSOSupCode(Val(ans$)), 0, FoundSup, sup     '20Mar01 TH Added to take account of possible invalid alternative sups
               strSupCode = PSOSupCode(Val(ans$))                              '20Mar01 TH
            Else                                                                  '15Jan00 TH Added
               popmessagecr "Patient Specific Ordering", "No supplier selected. Patient specific order cannot continue. " '    "
               k.escd = True                                                      '    "
            End If
         End If
      ElseIf intSuppliers = 1 Then
         strSupCode = PSOSupCode(1)
         'will order from supplier x ok/Cancel
         strAns = "Y"
         getsupplier strSupCode, 0, FoundSup, m_PSOSupplier
         '17Nov14 TH Added drug details to msg (TFS 79767)
         strDesc = strDesc & crlf & crlf & "Do you wish to order this item from : " & Trim$(strSupCode) & "(" & Trim$(m_PSOSupplier.name) & ")"
         askwin "Patient Specific Ordering", strDesc, strAns, k
         If strAns <> "Y" Then k.escd = True
      Else
         popmessagecr "Patient Specific Ordering", "This product has no PSO Suppliers. Patient specific order cannot continue. " '    "
         k.escd = True
      End If
      'If Not k.escd Then
      '   If Val(ans$) > 0 Then                                               '20Mar01 TH Added
      '      'getsupplier supcode$(Val(ans$) - 1), 0, foundsup%, False, sup     'Secondary supplier
      '      'Selected$ = supcode$(Val(ans$) - 1)
      '      getsupplier supcode$(Val(ans$) + invalidaltsup), 0, FoundSup, sup     '20Mar01 TH Added to take account of possible invalid alternative sups
      '      strSupCode = supcode$(Val(ans$) + invalidaltsup)                              '20Mar01 TH
      '      View = 1
      '   Else                                                                  '15Jan00 TH Added
      '      popmessagecr "#", "No suppliers have been setup for this product." '    "
      '      k.escd = True                                                      '    "
      '   End If
      '
      'End If
   Else                                                                               '15Jan00 TH Removed
      popmessagecr "Patient Specific Ordering", "Invalid Primary Supplier for this Product"  '    "
      k.escd = True                                                                   '    "
   End If                                                                             '    "

   If Not k.escd Then
      'Load supplier
      If Trim$(m_PSOSupplier.Code) = "" Then getsupplier strSupCode, 0, FoundSup, m_PSOSupplier
   Else
      clearsup m_PSOSupplier   '13Nov12 TH Added for completeness
   End If
      
      
   SelectPSOSupProfile = Not k.escd
      
End Function

Public Sub CreatePSOrder(ByVal sglQuantity As Single)
'15Aug12 TH Altered table to key on Label NOT Order (as Order may become 1:Many on Partial Receipt/Invoice etc.) (TFS 40931)(TFS 40713) (TFS 40789)
'13Nov12 TH Enhanced special message inout box (TFS 48650)
'29Aug14 TH Stop order creation on cancel from hub data entry screen. (TFS 98830)
'13Dec15 TH Removed New patient from none Hub order (Hub and None Hub should be aligned) (TFS 138047)

Dim PSOrd As orderstruct
Dim lngResult As Long
Dim strSup As String
Dim strParameters As String
Dim strText As String
Dim sErrDesc As String
Dim lErrNo As Long
Dim strDesc As String
Dim formPSO As FrmPSO
Dim blnNonMed As Boolean
Dim strDefaultNonMed As String
Dim blnOK As Boolean
Dim strAns As String
Dim msg As String
Dim strRenewal As String
Dim strOrderType As String
Dim PSOSup As supplierstruct
Dim bln_EHubOrder As Boolean
Dim strValid As String

On Error GoTo ErrorHandler

      k.escd = False
      '25Aug14 TH Further validation
      getsupplier m_PSOSupplier.Code, 0, 0, PSOSup
      If PSOSup.Method = "H" Then
         bln_EHubOrder = True
         strValid = ""
         Select Case LCase(Trim$(TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "nhnumber", "DefaultPatientID", 0)))
            'Case "nhnumber": If Trim$(pidExtra.NHNumber) = "" Then strValid = "Cannot raise eHub order as patient has no recorded " & GetNHSNumberDisplayName() & " number"
            Case "nhnumber": If Trim$(pidExtra.NHNumber) = "" Then strValid = "Cannot raise eHub order as patient has no recorded " & GetNHSNumberDisplayName() '27Aug14 TH "number" already included in display name (TFS 98726)
            Case "casenumber": If Trim$(pid.caseno) = "" Then strValid = "Cannot raise eHub order as patient has no recorded case number"
            Case "either": If (Trim$(pidExtra.NHNumber) = "") And (Trim$(pid.caseno) = "") Then strValid = "Cannot raise eHub order as patient has no recorded case number or " & GetNHSNumberDisplayName() & " number"
         End Select
         If Trim$(strValid) <> "" Then
            popmessagecr "eHub Ordering", strValid
            k.escd = True
         End If
      Else
         bln_EHubOrder = False
      End If
      '25Aug14 TH
      
      If Not k.escd Then '25Aug14 TH
         getdrugsup d, 0, 0, False, m_PSOSupplier.Code
         'strSup = Trim$(sup.name) & " (" & Trim$(sup.Code) & ")"
         'If Trim$(d.storesdescription) = "" Then
            'strDesc = Trim$(d.storesdescription)
         'Else
            'strDesc = Trim$(d.Description)
         'End If  XN 4Jun15 98073 New local stores description
                 strDesc = Trim$(d.DrugDescription)
         plingparse strDesc, "!"
         strSup = strDesc & crlf & crlf & "for patient : " & Trim$(pid.forename) & " " & Trim$(pid.surname) & crlf
         
         strSup = strSup & crlf & "from : " & Trim$(m_PSOSupplier.name) & " (" & Trim$(m_PSOSupplier.Code) & ")"  '09Nov12 TH (TFS)
         'Collect order information
         strText = ""
         'If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "", "Y", "eHubIntegration", 0)) Then
         If bln_EHubOrder Then '25Aug14 TH
            blnNonMed = (UCase$(Trim$(OCXheap("prescriptiontypedescription", ""))) = "NONMEDICINAL")
            strDefaultNonMed = "Service"
            strDefaultNonMed = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", strDefaultNonMed, "DefaultNonMed", 0)
            Set formPSO = New FrmPSO
            formPSO.lblDesc.Caption = strSup
            'Set Default Order Type
            If blnNonMed Then
               If UCase$(strDefaultNonMed) = "SERVICE" Then
                  formPSO.OptOrderType(1).Value = 1
               Else
                  formPSO.OptOrderType(2).Value = 1
               End If
            Else
               formPSO.OptOrderType(0).Value = 1
            End If
            'Default Renewal Stuff
            strRenewal = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "DefaultRenewalContact", 0)
            formPSO.txtRenewalContact = strRenewal
            formPSO.txtRenewalTelephone = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "DefaultRenewalTelNo", 0)
            formPSO.txtRenewaleMail = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "DefaultRenewalEmail", 0)
            'Here we want to collect information and display a new capture form.
            
            'Get the default for the order type -
            blnOK = False
            Do
               k.escd = False
               formPSO.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
               
               If k.escd Then
                  'Check this will be OK if not loop and reshow
                  strAns = "N"
                  'Produce a suitable msg
                  'msg = "This PSO Order will be raised as a " & IIf(blnOK, strDefaultNonMed, "medicinal product") & _'" and a new patient registration" & _
                  msg = "This PSO Order will be raised as a " & IIf(blnOK, strDefaultNonMed, "medicinal product") & _
                      Iff(Trim$(strRenewal) = "", "", crlf & "Renewal contact is " & strRenewal) & _
                      crlf & crlf & "Do you wish to continue"
                  askwin "?Patient Specific Order", msg, strAns, k
                  If strAns = "Y" Or k.escd Then
                     blnOK = True
                     formPSO.txtRenewalContact = strRenewal
                     formPSO.txtRenewalTelephone = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "DefaultRenewalTelNo", 0)
                     formPSO.txtRenewaleMail = TxtD(dispdata$ & "\PSO.ini", "eHubIntegration", "", "DefaultRenewalEmail", 0)
                     If blnNonMed Then
                        If UCase$(strDefaultNonMed) = "SERVICE" Then
                           formPSO.OptOrderType(1).Value = True
                        Else
                           formPSO.OptOrderType(2).Value = True
                        End If
                     Else
                        formPSO.OptOrderType(0).Value = True
                     End If
                  End If
               Else
                  'Validation check on Registration
                  'If formPSO.OptPatient(0).Value = 0 And formPSO.OptPatient(1).Value = 0 Then
                  '   popmessagecr "!Patient Specific Order", "You must specify whether this order requires a new patient registration"
                  'Else
                     blnOK = True
                  'End If
               End If
            
            Loop While Not blnOK
         Else
            strSup = crlf & crlf & strSup
            If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "", "Y", "CapturePSOOrderText", 0)) Then InputWin "Patient Specific Order", "Enter special instructions for:" & strSup, strText, k
            If k.escd Then strText = ""
            
         End If
         
         If Not (bln_EHubOrder And k.escd) Then '28Aug14 TH If Hub and cancel from Hub data capture - dont raise order.
         
            blankorder PSOrd
            PSOrd.Code = d.SisCode
            PSOrd.status = "1"
            PSOrd.qtyordered = LTrim$(Str$(sglQuantity))
            'ord.outstanding =
            PSOrd.outstanding = LTrim$(Str$(sglQuantity))
            'If Not PrintInPacks Then '19Jul12 TH (TFS 39281)
            PSOrd.qtyordered = LTrim$(Str$(Val(PSOrd.qtyordered) / d.convfact))
            PSOrd.outstanding = LTrim$(Str$(Val(PSOrd.outstanding) / d.convfact))
            'End If
            PSOrd.supcode = d.supcode
            PSOrd.num = 0
            PSOrd.convfact = d.convfact
            PSOrd.CreatedUser = UserID
            PSOrd.orddate = ""
            PSOrd.ordtime = ""
            PSOrd.custordno = ""
            PSOrd.DeliveryNoteReference = ""
            PSOrd.tofollow = 0
            PSOrd.received = 0
            If Val(d.contprice) > 0 Then
               PSOrd.cost = d.contprice
            Else
               If UCase$(d.sisstock) = "N" And Val(d.sislistprice) > 0 Then
                  PSOrd.cost = d.sislistprice 'price last paid
               Else
                  PSOrd.cost = d.cost
               End If
            End If
            PSOrd.pflag = ""
            PSOrd.PSORequestID = L.RequestID
            lngResult = PutOrder(PSOrd, 0, "WOrder") ' insert !
         
            'use lngResult as ID to link the order text Data
            'If TrueFalse(TxtD(dispdata$ & "\PSO.ini", "", "Y", "eHubIntegration", 0)) Then
            If bln_EHubOrder Then   '25Aug14 TH
               If formPSO.OptOrderType(1).Value = True Then
                  strOrderType = "Service"
               ElseIf formPSO.OptOrderType(2).Value = True Then
                  strOrderType = "Equipment"
               Else
                  strOrderType = "Medicinal"
               End If
               
               strText = formPSO.txtInstructions.text
               
               strParameters = gTransport.CreateInputParameterXML("PSO_requestID", trnDataTypeint, 4, L.RequestID) & _
                           gTransport.CreateInputParameterXML("OrderText", trnDataTypeVarChar, 50, strText) & _
                           gTransport.CreateInputParameterXML("PSOOrderType", trnDataTypeVarChar, 10, strOrderType) & _
                           gTransport.CreateInputParameterXML("Renewals_Contact_Name", trnDataTypeVarChar, 50, formPSO.txtRenewalContact.text) & _
                           gTransport.CreateInputParameterXML("Renewals_Contact_Telephone", trnDataTypeVarChar, 35, formPSO.txtRenewalTelephone.text) & _
                           gTransport.CreateInputParameterXML("Renewals_Contact_eMail", trnDataTypeVarChar, 50, formPSO.txtRenewaleMail.text) '& _
                           'gTransport.CreateInputParameterXML("New_Patient", trnDataTypeBit, 1, IIf((formPSO.OptPatient(0).Value = True), 1, 0))
               lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WPatientSpecificOrder", strParameters)
            Else
               If Trim$(strText) <> "" Then
                  strParameters = gTransport.CreateInputParameterXML("PSO_requestID", trnDataTypeint, 4, L.RequestID) & _
                                 gTransport.CreateInputParameterXML("OrderText", trnDataTypeVarChar, 50, strText) & _
                                 gTransport.CreateInputParameterXML("PSOOrderType", trnDataTypeVarChar, 10, "") & _
                                 gTransport.CreateInputParameterXML("Renewals_Contact_Name", trnDataTypeVarChar, 50, "") & _
                                 gTransport.CreateInputParameterXML("Renewals_Contact_Telephone", trnDataTypeVarChar, 35, "") & _
                                 gTransport.CreateInputParameterXML("Renewals_Contact_eMail", trnDataTypeVarChar, 50, "") '& _
                                 'gTransport.CreateInputParameterXML("New_Patient", trnDataTypeBit, 1, Null)
                                 '13Dec15 TH Removed New patient from none Hub order (these should be aligned (TFS 138047)
                  lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WPatientSpecificOrder", strParameters)
               End If
            End If
         End If '25Aug14 TH
      End If '28Aug14 TH Now dont write on escd.
      
      k.escd = False '28Aug14 TH Added - we dont care what is escaped here elsewhere.
      
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "CreatePSOrder", sErrDesc
     
      
End Sub

Public Function CheckPSOOrder(ByVal lngRequestID As Long) As Boolean
Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String

   On Error GoTo ErrorHandler
   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, lngRequestID)
   CheckPSOOrder = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsWLabelPSOcreated", strParameters)
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "CheckPSOOrder", sErrDesc

End Function

Public Function GetPSOSupplierText() As String


Dim lErrNo        As Long
Dim sErrDesc      As String

   GetPSOSupplierText = Trim$(m_PSOSupplier.name) & " (" & Trim$(m_PSOSupplier.Code) & ")"
   
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "GetPSOSupplierText", sErrDesc

End Function

Public Function CheckPendingPSOOrders(ByVal strNSVCode As String, ByVal lngPatientID As Long) As Boolean
'23Nov12 TH Written to provide checks on pending PSO Orders for this rx (TFS 49056)
'17Nov14 TH Added drug details to message (TFS 79766)

Dim strParameters As String

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim rsOrders      As ADODB.Recordset
Dim strMsg        As String
Dim blnResult     As Boolean
Dim strAns        As String
Dim strDOB        As String
Dim strDate       As String
Dim strDrug       As String
   On Error GoTo ErrorHandler
   strMsg = ""       'initialise
   blnResult = True  '  "
   
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
                   gTransport.CreateInputParameterXML("EnityID_Patient", trnDataTypeint, 4, lngPatientID)
   Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyPSOPatientandNSVCodeforDispensingCheck", strParameters)
   
   If Not rsOrders Is Nothing Then     'use returned recordset
      If rsOrders.State = adStateOpen Then
         If rsOrders.RecordCount <> 0 Then
            rsOrders.MoveFirst
            Do While Not rsOrders.EOF
               If RtrimGetField(rsOrders!status) = "1" Then
                  'Construct a sensible message
                  strMsg = strMsg & "Pending Order for " & Format$(RtrimGetField(rsOrders!qtyordered)) & " * " & Format$(RtrimGetField(rsOrders!convfact)) & " " & Format$(RtrimGetField(rsOrders!PrintformV))
                  strMsg = strMsg & " from " & Format$(RtrimGetField(rsOrders!SupplierName))
                  strMsg = strMsg & crlf & crlf
               ElseIf RtrimGetField(rsOrders!status) = "3" Then
                  'Construct a sensible message
                  strDate = Format$(RtrimGetField(rsOrders!DateOrdered))
                  If Len(strDate) Then
                     strDate = Left$(strDate, 2) + "/" + Mid$(strDate, 3, 2) + "/" + Right$(strDate, 4)
                  Else
                     strDate = "Not raised" 'should never happen
                  End If
                  strMsg = strMsg & "Order awaiting receipt for " & Format$(RtrimGetField(rsOrders!qtyordered)) & " * " & Format$(RtrimGetField(rsOrders!convfact)) & " " & Format$(RtrimGetField(rsOrders!PrintformV))
                  strMsg = strMsg & " from " & Format$(RtrimGetField(rsOrders!SupplierName))
                  strMsg = strMsg & crlf & "Order Number : " & Format$(RtrimGetField(rsOrders!OrderNumber)) & "  Raised on " & strDate
                  strMsg = strMsg & crlf & crlf
               End If
               
            
               rsOrders.MoveNext
            Loop
         End If
      End If
   End If
   'If we have some orders then display to user and ask if they want to continue
   If Trim$(strMsg) <> "" Then
      'Add header with patient info
      strDOB = Trim$(pid.dob)
      If Len(strDOB) Then
         strDOB = Left$(strDOB, 2) + "/" + Mid$(strDOB, 3, 2) + "/" + Right$(strDOB, 4)
      Else
         strDOB = "Not recorded"
      End If
      '17Nov14 TH Added drug details to message (TFS 79766)
      'strDrug = d.storesdescription
      'If Trim$(strDrug) = "" Then strDrug = d.Description   XN 4Jun15 98073 New local stores description
          strDrug = d.DrugDescription
      plingparse strDrug, "!"
      strDrug = d.SisCode & "   " & strDrug
      strMsg = "There are Patient specific orders already outstanding for :" & crlf & _
               "Patient : " & Trim$(pid.forename) & " " & Trim$(pid.surname) & "  (Date of Birth : " & strDOB & ")" & crlf & _
               GetNHSNumberDisplayName() & " : " & (OCXheap("HealthCareNumber", "Not Recorded")) & "  Case Number : " & Trim$(pid.caseno) & _
               crlf & crlf & _
               strDrug & crlf & crlf & strMsg
      strMsg = strMsg & crlf & "Do you wish to continue?"
      askwin "?EMIS Health", strMsg, strAns, k
      If strAns = "N" Or k.escd Then
         blnResult = False
      End If
   
   End If
   
   rsOrders.Close
   Set rsOrders = Nothing
   
   CheckPendingPSOOrders = blnResult
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & "CheckPSOOrder", sErrDesc

End Function
