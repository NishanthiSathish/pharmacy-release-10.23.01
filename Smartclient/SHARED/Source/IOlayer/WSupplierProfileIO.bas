Attribute VB_Name = "WSupplierProfileIO"
' WSupplierProfileIO
'------------
'08Oct06 TH  WSupplierProfile access module, released for testing
'            Locking not yet implemented
'23Jan08 TH  Added "S" store types to filter for supplier addition on profiles (F0011632)

Option Explicit
DefInt A-Z

Private Const OBJNAME As String = PROJECT & "WSupplierProfileIO."

Public Sub EditSupProfile(ByVal blnContractEditor As Boolean, ByRef blnEscaped As Boolean)
'30Jun99 CFY Written
'06Jan00 AW added facility to check for more than one seperator.
'07Jan00 AW added to allow escape.
'02May00 JP Added new fields for viewing
'10Feb00 TH  Added vatrate for GST and instigated SupProfile_callback
'05May00 JP removed restriction which only allows the selection window to be shown if secondary suppliers are present.
'24Jul00 TH Ensure default contract price is used rather than number in contprice field
'25Aug00 TH added code to maintain blank vatrates for sites with no Vatrate view
'20Mar01 TH Added to allow edit of primary supplier only, Trap for invalid default supplier
'20Mar01 TH and warn user of invalid alternatibe supplier and don't load these into the table (#46836)
'25Feb02 TH Now requires heap entry for changes to sup ref no to ensure correctly written to mdb (#58988)

Dim numoflines%, i%, FoundSup As Long, success%, NumOfEntries%, found%, View%
''Dim sup As supplierstruct
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

   ReDim Menu$(10), menuhlp%(10), supcode$(10)

   'Display list of suppliers for this drug
   Menu$(0) = "Edit Supplier Profile"

   'Add Primary supplier..
   getsupplier d.supcode, 0, FoundSup, sup
   If FoundSup Then                   '20Mar01 TH Added Check to ensure default supplier is valid
         'Menu$(1) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"

         'Add alternative supplier codes
         'deflines d.altsupcode, supcode$(), " ", 1, numoflines%
         seperator$ = " "
         strAltSups = GetAltenativeSupplierString(d.SisCode)
         'deflines d.altsupcode, supcode$(), seperator$, 1, numoflines%             '         "
         deflines strAltSups, supcode$(), seperator$, 1, numoflines% '22Jan07 TH Replaced
         If numoflines <= 1 Then                                                   '         "
               seperator$ = ","                                                    '         "
               deflines strAltSups, supcode$(), seperator$, 1, numoflines%       '         "
            End If                                                                 '         "
         If numoflines >= 1 Then
               For i% = 1 To numoflines%
                  getsupplier supcode$(i), 0, FoundSup, sup
                  If FoundSup Then
                        'menu$(i + 1) = sup.code & TB & TB & sup.name                 '20Mar01 TH Replaced with below
                        If UCase(Trim(d.supcode)) = UCase(Trim(sup.Code)) Then
                           Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"
                        Else
                           Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name '    "
                        End If
                     Else                                                                                   '20Mar01 TH Added
                        popmessagecr "", "Alternative Supplier " & supcode$(i) & " is not a valid supplier" '    "
                        invalidaltsup = invalidaltsup + 1
                     End If
               Next
               intAddNew = numoflines% + 1 - invalidaltsup
               Menu$(intAddNew) = "Add New Supplier Profile"
            End If
         inputmenu Menu$(), menuhlp%(), ans$, k
         If Not k.escd Then
''               If Val(ans$) = 1 Then
''                     getsupplier d.supcode, 0, foundsup, sup                   'Primary supplier
''                     Selected$ = d.supcode
''                     view = 2
''                  'Else                                                                   '20Mar01 TH Moved below
''                  ElseIf Val(ans$) > 1 Then                                               '20Mar01 TH Added
''                     'getsupplier supcode$(Val(ans$) - 1), 0, foundsup%, False, sup     'Secondary supplier
''                     'Selected$ = supcode$(Val(ans$) - 1)
''                     getsupplier supcode$(Val(ans$) - 1 + invalidaltsup), 0, foundsup, sup    '20Mar01 TH Added to take account of possible invalid alternative sups
''                     Selected$ = supcode$(Val(ans$) - 1 + invalidaltsup)                              '20Mar01 TH
''                     view = 1
''                  Else                                                                  '15Jan00 TH Added
''                     popmessagecr "#", "No suppliers have been setup for this product." '    "
''                     k.escd = True                                                      '    "
                  If Val(ans$) = intAddNew Then
                     'Here we need to add a new profile.
                     blnAddNew = True
                  ElseIf Val(ans$) > 0 Then                                               '20Mar01 TH Added
                     'getsupplier supcode$(Val(ans$) - 1), 0, foundsup%, False, sup     'Secondary supplier
                     'Selected$ = supcode$(Val(ans$) - 1)
                     getsupplier supcode$(Val(ans$) + invalidaltsup), 0, FoundSup, sup     '20Mar01 TH Added to take account of possible invalid alternative sups
                     strSupCode = supcode$(Val(ans$) + invalidaltsup)                              '20Mar01 TH
                     View = 1
                  Else                                                                  '15Jan00 TH Added
                     popmessagecr "#", "No suppliers have been setup for this product." '    "
                     k.escd = True                                                      '    "
                  End If
                  
            End If
            'Else                                                                               '15Jan00 TH Removed
            '   popmessagecr "#", "No alternative suppliers have been setup for this product."  '    "
            '   k.escd = True                                                                   '    "
      End If                                                                             '    "

   If Not k.escd Then
         'OpenSupProfileDB True, False
         If blnAddNew Then
            'Get a supplier /check it is valid
            blnContractEditor = False
            strSupCode = ""
            Do
               'asksupplier strSupCode, 0, "E", "Select a Supplier", False, sup
               asksupplier strSupCode, 0, "SE", "Select a Supplier", False, sup, False  '15Nov12 TH Added PSO param'10Jan08 TH Added Stores suppliers in Filter (F0011632)
               If Not (k.escd) And Trim$(strSupCode) <> "" Then
                  GetSupProfile d.SisCode, strSupCode, SupProfile, success%, found%
                  getsupplier strSupCode, 0, FoundSup, sup
                  If found Then
                     askwin "Supplier Profile", "A profile for this supplier already exists. Do you wish to edit this Profile ?", strAns, k
                     If strAns <> "Y" Then k.escd = True
                     
                  End If
               End If
            Loop While Trim$(strSupCode) = "" And (Not k.escd)
         Else
            GetSupProfile d.SisCode, strSupCode, SupProfile, success%, found%
            getsupplier strSupCode, 0, FoundSup, sup
         End If
         If success% And Not k.escd And Not blnContractEditor Then
               'If not found then populate record with default information from drug record.
               If Not found% Then
                     'SupProfile.tradename = d.tradename
                     SupProfile.contno = "" 'd.contno
                     SupProfile.reorderpcksize = d.reorderpcksize
                     'SupProfile.reorderlvl = d.reorderlvl
                     'SupProfile.reorderqty = d.reorderqty
                     SupProfile.sislistprice = d.sislistprice
                     'SupProfile.contprice = d.contno      '24Jul00 TH  Replaced
                     SupProfile.contprice = "0" 'd.contprice    '    "
                     SupProfile.LeadTime = d.LeadTime
                     SupProfile.lastreconcileprice = d.lastreconcileprice
                     SupProfile.SuppRefno = ""
                     SupProfile.SupplierTradeName = ""
                     'SupProfile.vatrate = "0"       '10Feb00 TH *GST*
                     SupProfile.vatrate = d.vatrate  '17Apr00 TH *GST*
                     SupProfile.WSupplierProfileID = 0
                  End If

               'Display supplier profile details for editing
               'View is dependant upon whether this is the primary or alternative supplier we are looking at.
               'ConstructView dispdata$ & "\supprof.ini", "views", "data", view, "", Not FullAccess, "", NumOfEntries
               ConstructView dispdata$ & "\supprof.ini", "views", "data", 1, "", False, "", NumOfEntries

               Ques.Caption = "Amend Supplier Profile for " & sup.name

               For i = 1 To NumOfEntries
                  Select Case Val(Ques.lblDesc(i).Tag)
                     Case 1:  txt$ = d.SisCode
                     Case 2:  txt$ = d.LabelDescription
                     Case 3:  txt$ = SupProfile.SupplierTradeName
                     Case 4:  txt$ = SupProfile.contno
                     Case 5:  txt$ = SupProfile.reorderpcksize
                     'Case 6:  txt$ = SupProfile.reorderlvl
                     'Case 7:  txt$ = SupProfile.reorderqty
                     Case 6:  txt$ = SupProfile.sislistprice
                     Case 7:  txt$ = SupProfile.contprice
                     Case 8: txt$ = SupProfile.LeadTime
                     Case 9: txt$ = SupProfile.lastreconcileprice
                     Case 10: txt$ = SupProfile.SuppRefno
                     'Case 13: txt$ = sup.discountval       '02May00 JP added extra fields
                     'Case 14: txt$ = sup.discountdesc      '  "              "
                     Case 11: txt$ = SupProfile.vatrate: Vatview = True '10Feb00 TH *GST* '25Aug00 TH added Vatview flag
                  End Select
                  QuesSetText i, Trim$(txt$)
               Next

               'QuesCallbackMode = 12
               QuesCallbackMode = 16  '10Feb00 TH *GST*
               QuesShow NumOfEntries
               QuesCallbackMode = 0
               If Ques.Tag <> "" Then
               If View = 1 And Vatview = False Then SupProfile.vatrate = "" '25Aug00 TH added to maintain blank vatrates for sites with no Vatrate view
                  For i = 1 To NumOfEntries
                     txt$ = QuesGetText(i)
                     Select Case Val(Ques.lblDesc(i).Tag)
                        Case 3:  SupProfile.SupplierTradeName = txt$
                        Case 4:  SupProfile.contno = txt$
                        Case 5:  SupProfile.reorderpcksize = txt$
                        'Case 6:  SupProfile.reorderlvl = txt$
                        'Case 7:  SupProfile.reorderqty = txt$
                        Case 6:  SupProfile.sislistprice = txt$
                        Case 7:  SupProfile.contprice = txt$
                        Case 8: SupProfile.LeadTime = txt$
                        Case 9: SupProfile.lastreconcileprice = txt$
                        Case 10:
                           SupProfile.SuppRefno = txt$
                           Heap 10, gPRNheapID, "sRefno", txt$, 0         '25Feb02 TH Now requires heap entry to ensure correctly written to mdb (#58988)
                        Case 11: SupProfile.vatrate = txt$    '10Feb00 TH *GST*
   
                     End Select
                  Next
   
                  SupProfile.SisCode = d.SisCode
                  SupProfile.supcode = sup.Code
                  'If Ques.Tag <> "" Then  '10Oct06 TH Moved above
                  askwin "?EMIS Health", "OK to save changes ?", ans$, k
                  If ans$ = "Y" Then
                     PutSupProfile SupProfile, success%
                     getdrug d, d.productstockID, 0, False '22Jan07 TH Reload drug cos we may have altered the def. supprof
                  End If
               End If
              '' OpenSupProfileDB False, False
               Unload Ques

            End If
      End If
      
      blnEscaped = k.escd
      
End Sub

Sub SupProfile_CallBack(ByVal intIndex As Integer)
'30Jun99 CFY Written
'10Feb00 TH Added check on Shift F1 - Vatrate
Dim ptr%, Code$, desc$

   'Nothing to do yet!!  --- Now there is

   If intIndex < 0 Then    'Shift-F1                                '10Feb00 TH
         ptr = Val(Ques.lblDesc(-intIndex).Tag)                     '   "
         Select Case ptr                                         '   "
            '!!**             Add lookups here (if any)          '   "
            Case 11                                              '   "
               ChooseVATcode Code$, desc$                        '   "
            End Select                                           '   "
         If Len(Code$) Then                                      '   "
                Ques.txtQ(-intIndex) = LTrim$(Code$)                '   "
                Ques.lblInfo(-intIndex) = desc$                     '   "
            Else                                                 '   "
                Ques.lblInfo(-intIndex) = "Shift-F1 for list"       '   "
            End If                                               '   "
      End If                                                     '   "


End Sub
Sub ChooseVATcode(Code$, desc$)
'27Jun97 CKJ Proc written
'03Oct08 TH  Changed rounding as arithmetic was showing 4.9999% instead of 5 % (F0024736)

Dim found&, cont&, x%, VATname$

   VATname$ = money$(9)
   LstBoxFrm.lblTitle = cr & "Choose " & VATname$ & " Code" & cr
   LstBoxFrm.lblHead = "Code     " & TB & VATname$ & " Rate"
   For x = 0 To 9
      'LstBoxFrm.LstBox.AddItem "  " & Format$(x) & TB & Format$((VAT(x) - 1) * 100) & " %"
      LstBoxFrm.LstBox.AddItem "  " & Format$(x) & TB & Format$(round(100 * (VAT(x) - 1), 2)) & " %" '03Oct08 TH (F0024736)
   Next
   
   LstBoxShow
   If LstBoxFrm.LstBox.ListIndex > -1 Then
         Code$ = Left$(Trim$(LstBoxFrm.Tag), 1)
      Else
         Code$ = ""
      End If
   desc$ = "Shift-F1 for list"
   Unload LstBoxFrm

End Sub
Public Function CheckForDuplicateSetPrimarySupplier(ByVal strNSVCode As String, ByVal strDate As String) As Boolean
'13Oct06 TH Written Given a profile update record, it checks to make sure no other profile for this Product is set to update
'                   the primary supplier on the same date.
Dim strParams As String
Dim rsWExtraDrugDetails As ADODB.Recordset
Dim lngCount As Long


   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) & _
               gTransport.CreateInputParameterXML("Date", trnDataTypeVarChar, 10, strDate)
   lngCount = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWExtraDrugDetailForPrimarySupCheck", strParams)
   If lngCount > 0 Then
   
      CheckForDuplicateSetPrimarySupplier = True
   Else
      CheckForDuplicateSetPrimarySupplier = False
   End If
               
End Function

