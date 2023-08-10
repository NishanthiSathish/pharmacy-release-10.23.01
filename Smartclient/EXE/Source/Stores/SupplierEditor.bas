Attribute VB_Name = "SupplierEditor"
'------------------------------------------------------------------------------------------------
'                SUPPLIER Editor Library
'------------------------------------------------------------------------------------------------
' Originally ported for version 8 to provide a quick editor for the supplier data types (wards,lists,external sups
' etc.) from version 9. Originally should have had new editors but there was no resource on ICW side to do this.

'RCNP008
'19Mar09 TH  Added fencepost to stop save on cancel (UHB) (F0032689)
'01Aug12 TH  AmendSuppliers: Leadtime added for V8 Compatibility (TFS 47507)
'01Aug12 TH  AmendSuppliers: Added PSO Flag
'06Aug12 TH  Supplier_Callback: Added new section for PSO flag support(TFS 40446)
'09Aug12 TH  Validation change after rethink .Stop PSO for none external supplier (TFS 41432)
'09Aug12 TH  Validation. Stop PSO selection for EDI Supplier (TFS 41011)
'15Nov12 TH  AmendSuppliers: Added PSO Validation changes (TFS 41432)
'06Dec12 TH  Supplier_Callback: (TFS 51001,51112)
'04Jan17 TH  EditorsPrintAll: Use DB Parsing (Hosted)(TFS 157969)
'07Jan17 TH  EditorsPrintAll: Refactored RTF check to DB (Hosted)(TFS 157969)
'12Jan17 TH  Editors Mods to use DB RTFs rather than files (Hosted)(TFS 157969)
'26Jan17 TH  CallEditPILs: Replacement for PIL Enabling (Hosted)(TFS 157969)
'26Jan17 TH  PILRTFsExistInDatabase written (Hosted)(TFS 157969)
'26Jan17 TH  EditorsPrintAll: Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)
'18Jul17 TH  Changed log handling to stop test of fileshare. (TFS 184877)

Option Explicit
'Const WARD_CODE_LEN = 5 ' 4      05Aug10 XN now uses the new GetWardCodeLen (F0051906)
Const modulename$ = "SupplierEditor.Bas"

Sub AmendSuppliers(ByVal asksuppliercode%, primersupcode$, escaped%)
''MsgBox "Supplier Editord are not available in ths application"
'SQL Editor not required (!) for SQL Version
'------------------------------------------------------------------------------
'                           Amend supplier details
'12Dec94 CKJ Mod in new supplier
' 2May97 CKJ Moved to supplier.bas and removed sup As supplierstruct from params
'27Jun97 CKJ Added "" to ConstructView
'29Jun97 EAC changed WSDB to SupDB
' 2Jul97 CKJ Replaced call to findsupplier with equivalent in-line code
' 5Aug97 CKJ Loop added when editing all suppliers
'            ReadOnly view now available (except for contract and notes)
'            For ReadOnly set asksuppliercode to a value other than 0 or -1, eg:
'                AmendSuppliers TRUE, "", escd           - edit all items
'                AmendSuppliers FALSE, "0001", escd      - edit item 0001 only
'                AmendSuppliers 1, "", escd              - view all items
'                AmendSuppliers 1, "0001", escd          - view item 0001 only
'08Feb98 CFY Extra code to handle ward type suppliers. Supplier code now copied to
'            field WardCode.
'18Mar98 CFY Removed section of code which adds a new wardcode to the array based list of
'            wardcodes as this task is done elsewhere.
'30Oct98 EAC Don't commit new suppliers until accepted by user
'24Nov98 TH  Ensure that date is saved to file in the right format
'27Nov98 TH  Now optimistic locking so that supplier file is not locked out
'17Mar99 CFY/SF now restricts supplier code length to that setup in stores.ini
'05Jan99 AW Changed to check for "<New>" rather than "New"
'20Apr00 CFY OnCost field added
'09Oct00 TH  added parameter to allow to differentiate store sup type
'30Mar01 AE  Added code for Inpatient directions ("1 hit" dispensing)
'06Apr01 JN  Changed references to IIF to IFF in AE's changes of 30Mar01
'23Mar01 TH  Allow blanking of Ward TopUpDate field (#48578)
'31Oct01 TH  Added AddHoc Delivery Note Print field
'15Jan02 TH  Added time for orderlog (#53214)
'19Mar09 TH  Added fencepost to stop save on cancel (UHB) (F0032689)
'19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
'05Aug10 XN  If customer is using 4 or 5 character ward code depenant on config setting Use5CharWardCode (F0051906)
'01Aug12 TH  Leadtime added for V8 Compatibility (TFS 47507)
'01Aug12 TH  Added PSO Flag (TFS 40446)
'09Aug12 TH  Validation change after rethink .Stop PSO for none external supplier (TFS 41432)
'09Aug12 TH  Validation. Stop PSO selection for EDI Supplier (TFS 41011)
'15Nov12 TH  Added PSO Validation changes (TFS 41432)
'22May14 XN  Editors: Moved Patient invoice to standard ICW report Editor 88863

'
'Problems
' Code allows sup code to be changed but makes no attempt to keep .mdb fields in sync
'  in fact orphan fields can be created
' Deletion of code no longer seems possible
' Wards do not have to have an internal site number
' I can't see how asksuppliercode=false, primersupcode="????" would work
'  - it doesn't seem to be setting the right variables
'  - how is it used?
'------------------------------------------------------------------------------
Dim newsup%, failed%, FoundSup As Long, found As Long
Dim supcode$, dat$
Dim pointer&, supfound&
Dim contname1$, contname2$, SQL$
'Dim snap As snapshot, tempdyn As Dynaset
Dim resumeval%, retries%, i%, txt$
Dim ViewNumber%, SetReadOnly%, LastView%, Viewname$, NumOfEntries%
Dim outdate$, valid%
Dim msg$, ans$ '06Feb98 CFY Added
Dim tempsup As supplierstruct             '30Oct98 EAC Added
Dim supwas As supplierstruct, supnow As supplierstruct, search$ '27Nov98 TH
Dim lines$(), Numoflines%                          '17Mar99 CFY/SF added
Dim RsExtraSupplierData As ADODB.Recordset    '26Jul04 TH
''Dim objDataAccess As clsDataAccess
Dim strParams As String
Dim supidxchanged As Boolean
Dim blnInsert As Boolean
Dim blnEdit As Boolean
Dim lngResult As Long
Dim orginalWardCode As String
Dim supnotes$ '21Jul14 TH Reinstated




Const procname$ = "AmendSuppliers"


   Select Case asksuppliercode                    ' 5Aug97 CKJ Added block
      Case True, False                            'allow updates
         SetReadOnly = False
         ViewNumber = 1                           'single fixed view at this time
      Case Else                                   'no updates
         SetReadOnly = True
         asksuppliercode = (primersupcode$ = "")  'ask only if no code supplied
         ViewNumber = 100                         'single fixed view without command buttons
   End Select

   Do
      ' 19May10 XN  Rebuild cache each time to get around not updating the Ward Codes (F0051906)
      FillWardCodeArraySQL True
      
      k.escd = False
      FoundSup = 0
      supcode$ = ""
      If asksuppliercode Then
         '2Jul97 CKJ Replaced with in-line code
         'findsupplier foundsup%, supcode$, True, True, sup  ' manual input of sup code
         asksupplier supcode$, Iff(SetReadOnly, 0, 2), "", "Enter supplier code", True, sup, False '15Nov12 TH Added PSO param (TFS 41432)
         If Not k.escd Then
            'If Trim$(supcode$) <> "NEW" Then getsupplier supcode$, 0, foundsup, False, sup      '30Oct98 Don't load supplier for new suppliers  '05Jan99 AW changed
            If Trim$(supcode$) <> "<NEW>" Then getsupplier supcode$, 0, FoundSup, sup                                                      '         "
         Else
            Exit Do                                   '5Aug97 CKJ Exit from edit all
         End If
      Else
         supcode$ = Trim$(UCase$(primersupcode$))
      End If

      newsup = False
      If Not k.escd And supcode$ = "<NEW>" Then
         Do
            setinput 0, k
            supcode$ = ""
            k.min = 1
            'k.max = Len(sup.code)                                                  '17Mar99 CFY/SF replaced
            ReDim lines$(10)                                                        '17Mar99 CFY/SF
            supcode$ = Trim$(TxtD$(dispdata$ & "\STORES.INI", "Data", "", "1", 0))  '17Mar99 CFY/SF
            deflines supcode$, lines$(), ",", 1, Numoflines%                        '17Mar99 CFY/SF
            k.Max = Val(lines$(2))                                                  '17Mar99 CFY/SF
            supcode$ = ""                                                           '17Mar99 CFY/SF
            newsup = True
            InputWin "New Supplier", "Enter new supplier code", supcode$, k
            ' get pointer to new record in supplier file
            If k.escd Then Exit Sub                                 '<== WAYOUT
            supcode$ = UCase$(supcode$)

            'SQL 16Jun05 TH Search here on Supcode by site. If > 0 then it pre-exists
            strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, supcode$)
            
            supfound& = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWSupplierCountbySupCodeandSiteID", strParams)
            
            If supfound& > 0 Then
               popmessagecr "Amend Site Details", supcode$ & " has already been defined in the Site file."
               supidxchanged = False
            Else
               supidxchanged = True
            End If
         Loop While Not supidxchanged
         clearsup sup                     '12Dec94 CKJ moved below getsupplier
         sup.Code = supcode$
         sup.Method = "D" '30Mar93CKJ
         sup.psis = "N"
         sup.ptn = "N"
         sup.inuse = "Y"

         'putsupplier foundsup, False, sup  '<------UNLOCK and write record 30Oct98 EAC Keep in memory until user confirmed they want to keep it
      End If

      If Not k.escd Then
         If FoundSup > 0 Then             'if supplier exists      '!!** THIS CANNOT BE RIGHT
            'getsupplier supcode$, foundsup, found, Not SetReadOnly, sup    '<------LOCK if not SetReadOnly
            getsupplier supcode$, FoundSup, found, sup    '27Nov98 TH  No Lock -Now optimistic locking
            supwas = sup                                         '27Nov98 TH  Copy Original sup for later comparison
         End If

         LastView = ViewNumber
         ConstructView dispdata$ & "\stores.ini", "views", "data", ViewNumber, "", SetReadOnly, Viewname$, NumOfEntries  '27Jun97 CKJ Added ""
         Ques.Caption = "Amend Supplier Details for " & Trim$(sup.Code) & " (" & Trim$(sup.name) & ")" '18Jul05 TH Added shortname (#81635)
   
         ''SQL$ = "SELECT * FROM ExtraSupplierData WHERE Supcode = '" & Trim$(sup.Code) & "';"
         'Set snap = SupDB.CreateSnapshot(SQL$) '29Jun97 EAC changed WSDB to SupDB
         'Set RsExtraSupplierData = SupDB.CreateSnapshot(SQL$)
         contname1$ = ""
         contname2$ = ""
         supnotes$ = ""
         '' Set objDataAccess = New clsDataAccess
         
         'strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
         '            gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, sup.Code)
         
         strParams = gTransport.CreateInputParameterXML("SupplierID", trnDataTypeint, 4, sup.SupplierID)
         
         If sup.suppliertype = "E" Then
            Set RsExtraSupplierData = gTransport.ExecuteSelectSP(g_SessionID, "pWSupplier2ExtraDataByWSupplier2ID", strParams)
         ElseIf sup.suppliertype = "W" Then
            Set RsExtraSupplierData = gTransport.ExecuteSelectSP(g_SessionID, "pWCustomerExtraDataByWCustomerID", strParams)
         ElseIf sup.suppliertype = "L" Then
            Set RsExtraSupplierData = Nothing 'gTransport.ExecuteSelectSP(g_SessionID, "pWCustomerExtraDataByWCustomerID", strParams)
         End If
         
         'If Not RsExtraSupplierData Then
         If Not RsExtraSupplierData Is Nothing Then
            If RsExtraSupplierData.RecordCount > 0 Then
               If Not RsExtraSupplierData.EOF Then
                  '21Jul14 TH Removed as now selected below
                  'contname1$ = Trim$(GetField(RsExtraSupplierData!ContactName1))
                  'contname2$ = Trim$(GetField(RsExtraSupplierData!ContactName2))
                  supnotes$ = Trim$(GetField(RsExtraSupplierData!notes))
               End If
            End If
            
            RsExtraSupplierData.Close
            Set RsExtraSupplierData = Nothing
         End If
         
         '24Jul14 TH
         contname1$ = Trim$(sup.UserField3)
         contname2$ = Trim$(sup.UserField4)
               
      ' 19May10 XN  Cach oringal code so don't get problem with couting it as a duplicate
        orginalWardCode = sup.wardcode

         For i = 1 To NumOfEntries
            Select Case Val(Ques.lblDesc(i).Tag)
               Case 1:  txt$ = sup.Code
               Case 2:  txt$ = sup.fullname
               Case 3:  txt$ = sup.contractaddress
               Case 4:  txt$ = sup.conttelno
               Case 5:  txt$ = sup.contfaxno
               Case 6:  txt$ = sup.supaddress
               Case 7:  txt$ = sup.suptelno
               Case 8:  txt$ = sup.supfaxno
               Case 9:  txt$ = sup.invaddress
               Case 10: txt$ = sup.invtelno
               Case 11: txt$ = sup.invfaxno
               Case 12: txt$ = sup.discountdesc
               Case 13: txt$ = sup.discountval
               Case 14: txt$ = QuesGetText(i)      'pragmatic - ie set caption=caption
               Case 15: txt$ = sup.ordmessage
               'Case 16: txt$ = contname1$
               'Case 17: txt$ = contname2$
               
               '21Jul14 TH use new fields from the supplier row
               Case 16: txt$ = sup.UserField3
               Case 17: txt$ = sup.UserField4
               
               Case 18: txt$ = QuesGetText(i)      '    "
               '
               Case 19: txt$ = supnotes$  '21Jul14 TH Reinstated
               Case 20: txt$ = sup.name
               Case 21: txt$ = sup.icode
               Case 22: txt$ = sup.ptn
               Case 23: txt$ = sup.psis
               '
               Case 25: txt$ = Iff(UCase$(sup.Method) = "D", "P", UCase$(sup.Method))
               Case 26: txt$ = sup.costcentre
               Case 27: txt$ = sup.suppliertype
               '
               Case 29: txt$ = sup.wardcode
               Case 30: txt$ = sup.PrintPickTicket
               Case 31: txt$ = sup.PrintDeliveryNote
               Case 32: txt$ = sup.ReceiveGoods
               Case 33: txt$ = sup.TopupInterval
               Case 34
                  txt$ = sup.topupdate
                  If Trim$(txt$) <> "" Then
                     parsedate txt$, outdate$, "dd-mmm-yyyy", valid
                     If valid Then txt$ = outdate$
                  End If
               Case 35: txt$ = sup.ATCSupplied
               Case 36: txt$ = UCase(sup.inuse)
               Case 37: txt$ = sup.onCost
               Case 38: txt$ = Iff(Val(sup.InPatientDirections) = 1, "Y", "N")         '30Mar01 AE Added    '06Apr01 JN Changed IIF to IFF
               Case 39: txt$ = Iff(sup.AdHocDelNote = "Y", "Y", "N")    '31Oct01 TH Added
               Case 40: txt$ = Format(sup.MinimumOrderValue, "#.##0.00")
               Case 41: txt$ = sup.LeadTime
               Case 42: txt$ = Iff(sup.PSO, "Y", "N")   '01Aug12 TH Added PSO (TFS 41432)(TFS 40446)
            End Select
            QuesSetText i, Trim$(txt$)
         Next

         If Not SetReadOnly Then
            Ques.F3D1.Tag = Str$(NumOfEntries)               'Not ideal but pragmatic
            Select Case Trim$(sup.suppliertype)              ' 4Aug97 CKJ Expanded
               Case "L":     SetWardSpecifics True, True, False    ' enable WardCode & ward details
               Case "W", "": SetWardSpecifics False, True, False   ' disable WardCode, enable ward details
               'Case Else:    SetWardSpecifics False, False   ' supplier/external                           '09Oct00 TH Removed
               Case "S":    SetWardSpecifics False, False, True  ' store                                   '09Oct00 TH added parameter
               Case Else:    SetWardSpecifics False, False, False ' supplier/external                      '09Oct00 TH added parameter
            End Select
         End If
         QuesMakeCtrl 0, 1000                 '12Aug97 CKJ Show print button

         QuesCallbackMode = 11
         QuesShow NumOfEntries                '<== Edit now
         QuesCallbackMode = 0

         If Trim$(Ques.Tag) <> "-1" Or SetReadOnly Then       '!!** But is HAS been - contact1/2, contract & notes already saved
  ''          If Not SetReadOnly Then popmessagecr "ESCAPED", "Site file not updated"
            k.escd = True
            Unload Ques '10Nov14 TH Added
         Else
            k.escd = False
            For i = 1 To NumOfEntries
               txt$ = QuesGetText(i)
               Select Case Val(Ques.lblDesc(i).Tag)
                  Case 1:  sup.Code = txt$
                  Case 2:  sup.fullname = txt$
                  Case 3:  sup.contractaddress = txt$
                  Case 4:  sup.conttelno = txt$
                  Case 5:  sup.contfaxno = txt$
                  Case 6:  sup.supaddress = txt$
                  Case 7:  sup.suptelno = txt$
                  Case 8:  sup.supfaxno = txt$
                  Case 9:  sup.invaddress = txt$
                  Case 10: sup.invtelno = txt$
                  Case 11: sup.invfaxno = txt$
                  Case 12: sup.discountdesc = txt$
                  Case 13: sup.discountval = txt$
                  'Case 14: "&Update"
                  Case 15: sup.ordmessage = txt$
                  
                  '21Jul14 TH Added new write to supplier record
                  Case 16: contname1$ = txt$: sup.UserField3 = txt$
                  Case 17: contname2$ = txt$: sup.UserField4 = txt$
                  
                  'Case 18: "&Edit Notes"
                  '
                  Case 19: supnotes$ = txt$
                  Case 20: sup.name = txt$
                  Case 21: sup.icode = txt$
                  Case 22: sup.ptn = txt$
                  Case 23: sup.psis = txt$
                  '
                  Case 25: sup.Method = Iff(txt$ = "P", "D", txt$)
                  Case 26: sup.costcentre = txt$
                  Case 27: sup.suppliertype = txt$
                  '
                  Case 29:
                        sup.wardcode = txt$
                        If sup.suppliertype = "W" Then
                           If Trim$(sup.wardcode) = "" Then
                              If Len(Trim$(sup.Code)) <= GetWardCodeLen() Then  ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs based on setting (F0051906)
                                 ' If ward code is not already set then reset code
                                 If Trim(sup.wardcode) = "" Then        ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
                                    ans$ = sup.Code$
                                 End If
                                 
                                 Do While (ans$ <> orginalWardCode$) And Not UniqueCode(ans$)   ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
                                    k.min = 1
                                    k.Max = GetWardCodeLen() ' 4     19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs based on setting (F0051906)
                                    msg$ = "ward code already in use." & cr & cr
                                    msg$ = msg$ & "Please re-enter."
                                    InputWin "EMIS Health", msg$, ans$, k
                                 Loop
                                 sup.wardcode = ans$
                              Else
                                 msg$ = "Supplier code too long to fit in Ward code." & cr & cr
                                 msg$ = msg$ & "Please enter new Ward code (max " & Trim$(Str$(GetWardCodeLen())) & " chars)"   ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs based on setting (F0051906)
                                 k.min = 1
                                 k.Max = GetWardCodeLen() ' 4     19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs based on setting (F0051906)
                                 InputWin "EMIS Health", msg$, ans$, k
                                 ans$ = UCase$(ans$)
                                 Do While (ans$ <> orginalWardCode$) And Not UniqueCode(ans$)   ' 19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs (F0051906)
                                    k.min = 1
                                    k.Max = GetWardCodeLen() ' 4     19May10 XN  Extended WSupplier.Wardcode from 4 to 5 charcs based on setting (F0051906)
                                    msg$ = "ward code already in use." & cr & cr
                                    msg$ = msg$ & "Please re-enter."
                                    InputWin "EMIS Health", msg$, ans$, k
                                 Loop
                                 sup.wardcode = ans$
                              End If
                           End If
                        ElseIf (sup.suppliertype = "E") Or (sup.suppliertype = "S") Then        ' 19May10 XN  (F0051906) Clear down ward code if S or E supplier as not needed
                            sup.wardcode = ""
                        End If
                        

                  Case 30: sup.PrintPickTicket = txt$
                  Case 31: sup.PrintDeliveryNote = txt$
                  Case 32: sup.ReceiveGoods = txt$
                  Case 33: sup.TopupInterval = txt$
                  Case 34:
                        If Trim$(txt$) <> "" Then '23Mar01 TH Allow blanking of date (#48578)
                           parsedate txt$, outdate$, "3", valid     '24Nov98 TH Ensure that date is saved to
                           If valid Then sup.topupdate = outdate$   '24Nov98 TH file in the right format
                        Else                   '23Mar01 TH
                           sup.topupdate = ""  '   "
                        End If                 '   "
                  Case 35: sup.ATCSupplied = txt$
                  Case 36: sup.inuse = txt$
                  Case 37: sup.onCost = txt$
                  Case 38: sup.InPatientDirections = Iff(UCase(txt$) = "Y", "1", "0")    '30Mar01 AE  Added.  flag is 1 or 0     '06Apr01 JN Changed IIF to IFF
                  Case 39: sup.AdHocDelNote = Iff(UCase(txt$) = "Y", "Y", "N")
                  Case 40: sup.MinimumOrderValue = Val(txt$)
                  Case 41: sup.LeadTime = txt$ '01Aug12 TH V8 Compatibility
                  Case 42: sup.PSO = Iff(UCase(txt$) = "Y", 1, 0) '01Aug12 TH Added (PSO) (TFS 41432)(TFS 40446)
                           '09Aug12 TH Validation after rethink (this is AGILE dude!!) Stop PSO for none external suppplier (TFS 41432)
                           If sup.PSO = True Then
                              If sup.Method = "E" Then
                                 popmessagecr "", "Patient Specific ordering is not supported for a Supplier using EDI ordering and will be set to off." _
                                 & crlf & "Please change the order method setting if you wish to enable Patient Specific Ordering"
                                 sup.PSO = False
                              ElseIf (sup.suppliertype <> "E") Then '09Aug12 TH PSO stop PSO selection for EDI Supplier (TFS 41011)
                                 popmessagecr "", "Patient Specific ordering is only supported for a external suppliers and will be set to off." _
                                 & crlf & "Please change the supplier type if you wish to enable Patient Specific Ordering"
                                 sup.PSO = False
                              End If
                           ElseIf (sup.Method = "H") Then
                                 popmessagecr "", "Patient Specific ordering currently must be set for all eHub suppliers." _
                                 & crlf & "Please change the order method if you wish to disable Patient Specific Ordering"
                                 sup.PSO = True
                           End If
               End Select
            Next
            
            '21Jul14 TH moved this as we can now only add/edit with a valid ID

''            Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
''            If RsExtraSupplierData.RecordCount < 1 Then
''
''               'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''               'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''               'blnInsert = True
''               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                           gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, sup.Code) & _
''                           gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, "") & _
''                           gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, "") & _
''                           gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, "") & _
''                           gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, Trim$(contname1$)) & _
''                           gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, Trim$(contname2$)) & _
''                           gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, "")
''               lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WExtraSupplierData", strParams)
''            Else
''               'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
''               'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
''               'tempdyn.Edit
''               strParams = gTransport.CreateInputParameterXML("WExtrSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
''                           gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                           gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
''                           gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!CurrentContractData)) & _
''                           gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!NewContractData)) & _
''                           gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, RtrimGetField(RsExtraSupplierData!DateofChange)) & _
''                           gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, Trim$(contname1$)) & _
''                           gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, Trim$(contname2$)) & _
''                           gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!notes))
''               lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
''            End If
''         End If

         Unload Ques

         ' This lump of code could be a lot tidier & more efficient !!
         If Not k.escd Then '19Mar09 TH why are we writing when we cancel out ?? (UHB)
            If FoundSup <= 0 Then          ' new supplier code
               If Not k.escd Then
                  If supcode$ = "" Then
                     popmessagecr "WARNING", "Supplier code is blank - record not saved"
                     k.escd = True
                  Else
                    'foundsup = pointer&
                     'getsupplier supcode$, foundsup, found, True, tempsup  '@~@~  '<LOCK
                     putsupplier FoundSup, sup    'Need ID to send to SQL (here ID 0)                 '<------UNLOCK and write record if not k.escd
                     '11Oct05 TH Added block
                     If newsup Then
                        setSupplierCacheEntries 0 '11Oct05 TH Ensure new supplier is recached at next opportunity
                        dat$ = thedate(False, True) '03May98 CKJ Y2K
                        dat$ = dat$ & thedate(0, -2)  '15Jan02 TH Added time for log (#53214)
                        'Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "" '14Jan94 CKJ No VAT here
                        'Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "", ""  '02Nov10 AJK F0086901 Added paydate
                        Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "", "", 0 '03Mar14 TH Added PSORequestID
                     End If
                     '11Oct05 TH
                     'getsupplier supcode$, 0, found, False, sup  '@~@~  '<no lock
                     'If found Then
                     '      popmessagecr "WARNING", "Supplier code " + supcode$ + " already exists - record not saved"
                     '      k.escd = True
                     '   End If
                     '---
                     
                     '21Jul14 TH Added (now actually should save the notes, though only those)
                     If InStr(sup.suppliertype, "W") > 0 Then
                        strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                                       gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WCustomerExtraDataNotesWrite", strParams)
                     ElseIf InStr(sup.suppliertype, "SE") > 0 Then
                        'strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                        '            gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, contname1$) & _
                        '            gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, contname2$) & _
                        '            gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        strParams = gTransport.CreateInputParameterXML("WSupplier2ID", trnDataTypeint, 4, sup.SupplierID) & _
                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WSupplier2ExtraDataNotesWrite", strParams)
                     End If
                     
                  End If
               End If
            Else                                   ' existing supplier
               If Not SetReadOnly Then
                  If Trim$(supcode$) <> Trim$(sup.Code) Then
                     If Not k.escd Then
                        If Trim$(sup.Code) = "" Then
                           popmessagecr "WARNING", "Supplier code is blank - record not saved"
                           k.escd = True
                        Else
                           getsupplier Trim$(sup.Code), 0, found, sup   '@~@~  '<no lock
                           If found Then
                              popmessagecr "WARNING", "Supplier code " + Trim$(sup.Code) + " already exists - record not saved"
                              k.escd = True
                           End If
                        End If
                     End If
                  End If
                  'make checks (optimistic locking) here                                                  '27Nov98 TH Added
                  getsupplier Trim$(sup.Code), 0, found, supnow  'Used to lock here                                '27Nov98 TH Added
                  search$ = Space$(Len(supnow))                                                        '27Nov98 TH Added
                  LSet r = supnow                                                                      '27Nov98 TH Added
                  LSet search$ = r.record                         ' copy whole structure to a string   '27Nov98 TH Added
                  LSet r = supwas                                 ' copy original as well              '27Nov98 TH Added
                  If search$ <> Left$(r.record, Len(supnow)) Then ' and compare                        '27Nov98 TH Added
                     putsupplier FoundSup, supnow                                           '27Nov98 TH Added
                     popmessagecr "Save Supplier", "Can't save Supplier changes - record has been changed since it was read"         '27Nov98 TH Added
                  Else                                                                              '27Nov98 TH Added
                     putsupplier FoundSup, sup                                              '27Nov98 TH Added
                  End If                                                                            '27Nov98 TH Added
                  If newsup Then
                     setSupplierCacheEntries 0 '11Oct05 TH Ensure new supplier is recached at next opportunity
                     dat$ = thedate(False, True) '03May98 CKJ Y2K
                     dat$ = dat$ & thedate(0, -2)  '15Jan02 TH Added time for log (#53214)
                     'Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "" '14Jan94 CKJ No VAT here
                     'Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                     Orderlog "", "", UserID$, dat$, "", "", "", "", sup.Code, "C", SiteNumber, "", "1", "", "", "", "", 0  '03Mar14 TH Added PSORequestID
                  End If
                  '21Jul14 TH Added (now actually should save the notes, though only those)
                  If InStr(sup.suppliertype, "W") > 0 Then
                     strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                     lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWCustomerExtraDataNotesWrite", strParams)
                  ElseIf InStr(sup.suppliertype, "SE") > 0 Then
                     'strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                     '            gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, contname1$) & _
                     '            gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, contname2$) & _
                     '            gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                     'lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WSupplierExtraDataWrite", strParams)
                     strParams = gTransport.CreateInputParameterXML("WSupplier2ID", trnDataTypeint, 4, sup.SupplierID) & _
                                 gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                     lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WSupplier2ExtraDataNotesWrite", strParams)
                     
                  End If
                  
               End If
            End If
         End If '19Mar09 TH
      End If
      End If
   Loop While asksuppliercode = True  '5Aug97 CKJ If editing all suppliers, loop until exit

   ''If Not SetReadOnly Then sortindex "Supplier Index", dispdata$ & "\supfile.idx"

   escaped% = k.escd           'return whether or not process was aborted
   primersupcode$ = supcode$   'return selected supplier code

   ''m_lngSupplierCacheEntries = 0   '28Sep99 CKJ Added to force re-read of cache
   setSupplierCacheEntries 0

Exit Sub

 '           For i = 1 To NumOfEntries                '!!** Incorporate logging?
 '              tmp$ = QuesGetText(i)
 '              Ptr = Val(Ques.lblDesc(i).Tag)
 '              If tmp$ <> RTrim$(presentent$(Ptr)) Then
 '                    info$ = pad$((Ques.lblDesc(i)), 25) & " " & "Was : '" & RTrim$(presentent$(Ptr)) & "' Now : '" & tmp$ & "'"
 '                    Summary$ = Summary$ & info$ & cr
 '                    SomeChange = True
 '                    'log changes here
 '                    writelog rootpath$ + "\labutils.log", site, userid$, d.siscode & " " & info$
 '                 End If
 '              presentent$(Ptr) = tmp$
 '           Next
 '           'If Len(Summary$) Then popmessagecr "", Summary$    'for debugging
 '           Unload Ques
 '           If FixedView Then ViewNumber = 0     'exit

USUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)    '!!**'@~@~
   Select Case resumeval
      Case -1: Resume
      Case 0:  Resume Next
      'Case 1:  Close: End    'TerminateApp       '!!**
      '23Jun05 TH No Ends!!! - need to handle this
      End Select
               
End Sub

Sub Supplier_Callback(Index%)
'''29Jun97 EAC changed WSDB to SupDB
''' 4Aug97 CKJ modified mandatory fields
''' 5Aug97 CKJ added on error round setfocus
'''23Feb98 EAC Detect when suppliertype is changed to a "W" type supplier and set WardCode field to blank so that it will be updated uniquelly when exiting from AmendSuppliers
'''25Feb98 EAC Added T order type for Transfer of stock, NB this mod required changes to STORES.INI
'''17Mar98 CKJ Corrected blanking of ward code: It must not change the 29th Item, it must change
'''            the item which has the tag = 29. This will vary with different views.
'''18Mar98 CFY Added code to delete entries from the wardcode array when the wardcode field is set to blank.
'''09Apr98 CFY Extra code to fill the contactname fields inf the extrasupplierdata tablewith a space.
'''            This prevents the database causing an error on addnew. This method was taken in preference to
'''            changing the table definition.
'''22Jan99 TH  Added check on print picking tickets/del notes for ward Lists
'''09Oct00 TH  Added parameter to allow differentiation of Store type suppliers
'''21Jun01 TH  Fencepost wardcode deletion for wardtype selection (GPF experienced when using saveasnewward) (#53395)
'''28Jan04 TH  Added check on in use to see if the supplier has outstanding reqs or to warn user to check for outstanding orders (#72056)
'''13Mar04 TH  Mod to above and bad date msg from topup date - Could be calling msgbox while do events still modally shown, so unload doevents first
'''16Mar04 TH  Removed mods (28Jan04,13Mar04) after discussion with CKJ - procedures called from here remain active in code, but
'''            now should never be called until (if) this mod is reinstated.
'''13May04 CKJ Added non-mandatory message, and used it to prompt user when changing Inuse flag
'''24may04 ckj removed last mod. Instead use variable text next to the InUse box, taken from stores.ini [Info] 36= and 36YSE=
'06Aug12 TH  Added new section for PSO flag support(TFS 40446)
'06Dec12 TH  (TFS 51001,51112)

Const procname$ = "Supplier_Callback"

Dim outdate$
Dim SQL$, msg$, NewIndex%, tmp$, NoText%, WdNoText%, SENoText%
''Dim tempdyn As dynaset
Dim resumeval%, retries%, valid%, txt$, change%, i%
Dim ptr%, sitetype$
Dim LNoText%, temp$        '22Jan99 TH
'Dim strSupMsg As String    '28Jan04 TH Added
Dim RsExtraSupplierData As ADODB.Recordset
Dim strParams As String
Dim lngResult As Long
''Dim supnotes$

      If Index < 0 Then    'Shift-F1
         ptr = Val(Ques.lblDesc(-Index).Tag)
         Select Case ptr
            '!!**             Add lookups here (if any)
         End Select

      ElseIf Index = 1000 Then                                    '12Aug97 CKJ Print
         QuesPrintView "", "Location File :   +"

      Else
         ptr = Val(Ques.lblDesc(Index).Tag)
         txt$ = QuesGetText(Index)
         msg$ = ""
         Select Case ptr  'Index
            Case 0        'OK button pressed
               For i = 1 To Val(Ques.F3D1.Tag)                    '1 to Number of controls created
                  If Val(Ques.lblDesc(i).Tag) = 27 Then           'found the line for site type
                        sitetype$ = UCase$(Trim$(QuesGetText(i))) 'found sitetype
                        Exit For
                     End If
               Next

               For i = 1 To Val(Ques.F3D1.Tag)                    '1 to Number of controls created
                  txt$ = QuesGetText(i)
                  tmp$ = ""
                  NoText = (txt$ = "")
                  WdNoText = NoText And sitetype = "W"
                  SENoText = NoText And (sitetype = "S" Or sitetype = "E")
                  LNoText = NoText And sitetype = "L"    '22Jan99 TH
                  If sitetype = "L" Then temp$ = " list" '22Jan99 TH

                  Select Case Val(Ques.lblDesc(i).Tag)            'reference number of line
                     Case 1:  If NoText Then tmp$ = "You must enter a code for this site" & cr
                     Case 2:  If NoText Then tmp$ = "Please enter the full name of this Site" & cr
                     Case 20: If NoText Then tmp$ = "Please enter the short name of this Site" & cr
                     Case 22: If SENoText Then tmp$ = "Please specify if the trade name is to be printed on orders for this site" & cr
                     Case 23: If SENoText Then tmp$ = "Please specify if the NSV code is to be printed on orders for this site" & cr
                     Case 25: If SENoText Then tmp$ = "Please enter the order output type" & cr
                     Case 27: If NoText Then tmp$ = "Please enter the Site type for this location" & cr
                     'Case 21: If WdNoText Then tmp$ = "Please enter the Internal Site Code for this ward" & cr '4Aug97 CKJ/EAC Now optional - defaults to own site
                     'Case 30: If WdNoText Then tmp$ = "Please specify if Picking Tickets are to be printed for this ward" & cr
                     'Case 31: If WdNoText Then tmp$ = "Please specify if Delivery Notes are to be printed for this ward" & cr
                     Case 30: If WdNoText Or LNoText Then tmp$ = "Please specify if Picking Tickets are to be printed for this ward" & temp$ & cr  '22Jan99 TH
                     Case 31: If WdNoText Or LNoText Then tmp$ = "Please specify if Delivery Notes are to be printed for this ward" & temp$ & cr   '22Jan99 TH
                     Case 32: If WdNoText Then tmp$ = "Please specify if this ward will Receive Goods" & cr
                     Case 33: If WdNoText And TrueFalse(TxtD(dispdata$ & "\Stores.ini", "", "Y", "TopUpWarnings", 0)) Then tmp$ = "Please specify the Topup Interval for this ward" & cr '!!** Surely not mandatory '10Oct05 Well, at least on default (#81645)

                     Case 34
                        If sitetype = "W" And Not NoText Then
                              parsedate txt$, outdate$, "3", valid
                              If valid Then
                                    QuesSetText i, outdate$
                                 Else
                                    BadDate
                                    tmp$ = " "               'just to set the error flags
                                 End If
                           End If

                     Case 35: If WdNoText Then tmp$ = "Please specify if this ward uses an ATC" & cr
                     'Case 36: If sitetype = "E" Or sitetype = "S" Then strWarn = "Please ensure there are no outstanding Orders or Invoices for this Supplier" & cr   '13May04 CKJ 24may04 CKJ removed
                     End Select

                  If Len(tmp$) Then
                     msg$ = msg$ & tmp$
                     If NewIndex = 0 Then NewIndex = i
                  End If
               Next
               If Len(msg$) Then Ques.Tag = ""

            Case 14                                          'Amend contract details
               'If Trim$(Ques.txtQ(27).Text) = "" Then
               '      popmessagecr "Amend Site", "Please specify what kind of site this is."
               '      Ques.txtQ(27).SetFocus
               '      Exit Sub
               '   End If

               'If Trim$(Ques.txtQ(27).Text) <> "E" Then
               '      popmessagecr "Amend Site", "Can only specify Contract Details for External Suppliers."
               '   Else
               If sup.SupplierID = 0 Then '21Jul14 TH Backwards compatibility means the ID link is essential - this then must be a known limitation
                  popmessagecr "Error", "Supplier/Ward record must be saved before editing contract details."
               Else
                  If Trim$(sup.Code) = "" Then
                     popmessagecr "Error", "No supplier code defined."
                  Else
                     ContractEditor.Tag = sup.Code
                     ContractEditor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
                  End If
               '   End If
               End If

            Case 18                                          'Edit notes
               If sup.SupplierID = 0 Then '21Jul14 TH Backwards compatibility means the ID link is essential - this then must be a known limitation
                  popmessagecr "Error", "Supplier/Ward record must be saved before editing notes."
               Else
                  change = True
                  TextEdit "Notes for Supplier '" & sup.Code & "'", supnotes$, "", change, False
                  If change Then
                     '21Jul14 TH Replace below
                     If InStr(sup.suppliertype, "W") > 0 Then
                        strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                                       gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WCustomerExtraDataNotesWrite", strParams)
                     ElseIf InStr(sup.suppliertype, "SE") > 0 Then
                        'strParams = gTransport.CreateInputParameterXML("WCustomerID", trnDataTypeint, 4, sup.SupplierID) & _
                        '            gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, contname1$) & _
                        '            gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, contname2$) & _
                        '            gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        strParams = gTransport.CreateInputParameterXML("WSupplier2ID", trnDataTypeint, 4, sup.SupplierID) & _
                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WSupplier2ExtraDataNotesWrite", strParams)
                     End If
                  
                  
                  
                     Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(sup.Code)
                     If RsExtraSupplierData.RecordCount < 1 Then
                        
                        'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
                        'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
                        'blnInsert = True
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, sup.Code) & _
                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, "") & _
                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, "") & _
                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, "") & _
                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, " ") & _
                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, " ") & _
                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WExtraSupplierData", strParams)
                     Else
                        'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
                        'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
                        'tempdyn.Edit
''                        strParams = gTransport.CreateInputParameterXML("WExtraSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
''                                    gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
''                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, TxtEdit(0)) & _
''                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, TxtEdit(1)) & _
''                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, TxtUpdDate) & _
''                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName1)) & _
''                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName2)) & _
''                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
''                        lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
                        
                        strParams = gTransport.CreateInputParameterXML("WExtraSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
                                    gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
                                    gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!CurrentContractData)) & _
                                    gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, RtrimGetField(RsExtraSupplierData!NewContractData)) & _
                                    gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, RtrimGetField(RsExtraSupplierData!DateofChange)) & _
                                    gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName1)) & _
                                    gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName2)) & _
                                    gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
                        lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
                     End If
''                     SQL$ = "SELECT * FROM ExtraSupplierData WHERE supcode = '" & sup.Code & "';"
''                     Set tempdyn = SupDB.CreateDynaset(SQL$) '29Jun97 EAC changed WSDB to SupDB
''                     tempdyn.LockEdits = False
''                     If Not tempdyn.EOF Then
''                           tempdyn.Edit
''                        Else
''                           tempdyn.AddNew
''                           tempdyn!supcode = Trim$(sup.Code)
''                           tempdyn!ContactName1 = " "       '09Apr98 CFY Added
''                           tempdyn!ContactName2 = " "       '09Apr98 CFY Added
''                        End If
''                     tempdyn!notes = supnotes$
''                     On Error GoTo QCUpdateTableErr
''                     tempdyn.Update
''                     On Error GoTo 0
''                     tempdyn.Close
''                     Set tempdyn = Nothing
                  End If
                  
                  Unload Editor
               
               End If
               
            Case 22, 23                                      'Trade Name & NSV code
               If Trim$(txt$) = "" Then Ques.txtQ(Index).text = "N"

            Case 25
               Select Case txt$
                  Case "E"
                     For i = 1 To Val(Ques.F3D1.Tag)
                        If Val(Ques.lblDesc(i).Tag) = 42 Then
                           If Ques.txtQ(i).text = "Y" Then
                              'On Error Resume Next      '06Dec12 TH (TFS 51001,51112)
                              'Unload frmDoEvents        '   "
                              'If Err Then               '   "
                              '   Err = 0                '   "
                              'End If
                              'popmessagecr "ERROR", "Patient Specific ordering is not supported for a Supplier using EDI ordering"
                              'On Error GoTo 0
                              tmp$ = "Patient Specific ordering is not supported for a Supplier using EDI ordering"
   
                           End If
                        End If
                     Next
                  'Case "P", "F", "I", "X", "M", "T"        '25Feb98 EAC added "T" for stock Transfer
                  Case "P", "F", "E", "I", "T" ', "H"      '20Aug14 TH Added "H" eHub type ordering
                  ''Case "P", "F", "E", "I", "T"        '13Oct05 TH Removed M and X
                  Case "H"
                   For i = 1 To Val(Ques.F3D1.Tag)
                     If Val(Ques.lblDesc(i).Tag) = 42 Then
                        If Ques.txtQ(i).text = "N" Then
                           'On Error Resume Next      '06Dec12 TH (TFS 51001,51112)
                           'Unload frmDoEvents        '   "
                           'If Err Then               '   "
                           '   Err = 0                '   "
                           'End If
                           'popmessagecr "ERROR", "Patient Specific ordering is not supported for a Supplier using EDI ordering"
                           'On Error GoTo 0
                           tmp$ = "Patient Specific ordering must be enabled for a Supplier using eHub ordering"

                        End If
                     End If
                  Next
                  Case Else
                     'Ques.txtQ(Index).SetFocus  '@~@~
                     ''popmessagecr "ERROR", "Invalid character" & cr & "Please enter P, F, E, I, X or M"
                     'popmessagecr "ERROR", "Invalid character" & cr & "Please enter P, F, E or I" '13Oct05 TH Removed X (?) and M (Modem)
                     popmessagecr "ERROR", "Invalid character" & cr & "Please enter P, F, E, I or H" '11Nov14 TH Added H (Hub)
                  End Select

            Case 27
               Select Case txt$                                  ' 4Aug97 CKJ Expanded
                  Case "L":      SetWardSpecifics True, True, False    ' enable WardCode & ward details   '09Oct00 TH added parameter
                  Case "W":
                     SetWardSpecifics False, True, False   ' disable WardCode, enable ward details '09Oct00 TH added parameter
                     'If sup.suppliertype <> "W" Then Ques.txtQ(29).Text = ""   '23Feb98 EAC Detect when suppliertype is changed to a "W" type supplier and set WardCode field to blank so that it will be updated uniquelly when exiting from AmendSuppliers
                     'If sup.suppliertype <> "W" Then             '17Mar98 CKJ Corrected: It must not change the 29th Item, it must change the item which has the tag = 29. This will vary with different views
                     If sup.suppliertype <> "W" And Trim$(sup.suppliertype) <> "" Then  '21Jun01 TH could be a new ward (GPF experienced when using saveasnewward)
                        For i = 1 To Val(Ques.F3D1.Tag)       '1 to Number of controls created
                           If Val(Ques.lblDesc(i).Tag) = 29 Then
                              DelWardArrayEntry QuesGetText(i) '18Mar98 CFY Added
                              QuesSetText i, ""            'blank the ward code
                              Exit For                     'quit loop
                           End If
                        Next
                     End If
                  'Case "S", "E": SetWardSpecifics False, False   ' supplier  '09Oct00 TH Replaced
                  Case "E": SetWardSpecifics False, False, False  ' supplier  '09Oct00 TH added parameter
                  Case "S": SetWardSpecifics False, False, True  ' store      '09Oct00 TH added parameter
                  Case Else
                     'Ques.txtQ(Index).SetFocus  '@~@~
                     popmessagecr "ERROR", "Invalid character" & cr & "Please enter W, L, S or E."
               End Select

            Case 34
               
               If Trim$(txt$) <> "" Then
                  parsedate txt$, outdate$, "dd-mmm-yyyy", valid
                  If valid Then
                     QuesSetText Index, outdate$
                  Else
                     '16Mar04 TH Removed mod after discussion with CKJ
                     'On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
                     'Unload frmdoevents        '   "
                     'If Err Then               '   "
                     '   Err = 0                '   "
                     'End If                    '   "
                     '16Mar04 TH ----------------------
                     BadDate
                     If NewIndex = 0 Then NewIndex = 34
                  End If
               End If

            '16Mar04 TH Removed mod after discussion with CKJ
            '28Jan04 TH Added section
            'Case 36 'InUse
            '   If truefalse(txtd(dispdata$ & "\winord.ini", "", "Y", "SupplierReqCheck", 0)) Then
            '      If Trim$(txt$) = "N" Then
            '         'Now run checks on whether there are oustanding orders/requisitions/reconciliations
            '         strSupMsg = SupplierOrderChecks(sup.code, sup.suppliertype)
            '         If strSupMsg <> "" Then
            '               'On Error Resume Next
            '               On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
            '               Unload frmdoevents        '   "
            '               If Err Then               '   "
            '                  Err = 0                '   "
            '               End If                    '   "
            '               popmessagecr "!WARNING", strSupMsg
            '               On Error GoTo 0
            '         Else
            '            If Trim$(UCase$(sup.suppliertype)) = "E" Or Trim$(UCase$(sup.suppliertype)) = "S" Then
            '               strSupMsg = txtd(dispdata$ & "\winord.ini", "", "Please ensure there are no outstanding Orders or Invoices for this Supplier !", "SupplierNoOrdsMsg", 0)
            '                  'On Error Resume Next
            '                  On Error Resume Next      '13Mar04 TH Could be calling msgbox while do events still modally shown
            '                  Unload frmdoevents        '   "
            '                  If Err Then               '   "
            '                     Err = 0                '   "
            '                  End If                    '   "
            '               popmessagecr "!WARNING", strSupMsg
            '                  On Error GoTo 0
            '            End If
            '         End If
            '      End If
            '   End If
            '-----------

            Case 36                         'InUse Y/N                        '24may04 ckj block added
               tmp$ = "36"                                                    'default
               For i = 1 To Val(Ques.F3D1.Tag)                                '1 to Number of controls created
                  If Val(Ques.lblDesc(i).Tag) = 27 Then                       'found the line for site type
                     Select Case UCase$(Trim$(QuesGetText(i)))             'found sitetype
                        Case "E", "S"
                           If txt$ <> "Y" Then                             'External type supplier, set Not in use
                              tmp$ = "36YSE"                            'warning message
                           End If
                     End Select
                     Exit For
                  End If
               Next
               Ques.lblInfo(Index).Caption = TxtD(dispdata$ & "\stores.ini", "Info", "Y/N", tmp$, 0)
            '06Aug12 TH Added new section for PSO (TFS 40446)
            Case 42
                  For i = 1 To Val(Ques.F3D1.Tag)
                     If Val(Ques.lblDesc(i).Tag) = 27 Then
                        If Ques.txtQ(i).text <> "E" Then
                           'On Error Resume Next      '06Dec12 TH (TFS 51001,51112)
                           'Unload frmDoEvents        '   "
                           'If Err Then               '   "
                           '   Err = 0                '   "
                           'End If
                           'popmessagecr "ERROR", "Patient Specific ordering is only supported for a external suppliers"
                           'On Error GoTo 0
                           tmp$ = "Patient Specific ordering is only supported for a external suppliers"
                           Exit For
                        End If
                     End If
                     If Val(Ques.lblDesc(i).Tag) = 25 Then
                        If Ques.txtQ(i).text = "E" Then
                           'On Error Resume Next      '06Dec12 TH (TFS 51001,51112)
                           'Unload frmDoEvents        '   "
                           'If Err Then               '   "
                           '   Err = 0                '   "
                           'End If
                           'popmessagecr "ERROR", "Patient Specific ordering is not supported for a Supplier using EDI ordering"
                           'On Error GoTo 0
                           tmp$ = "Patient Specific ordering is only supported for a external suppliers"
                        End If
                     End If
                     
                  Next
                  
               
         End Select

         If Trim$(msg$) <> "" Then
            popmessagecr "!Information missing", msg$
            On Error Resume Next                              '5Aug97 CKJ Added
            Ques.txtQ(NewIndex).SetFocus
            On Error GoTo 0
         End If
      End If

Exit Sub

QCUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)        '!!**
   Select Case resumeval
      Case -1: Resume
      Case 0:  Resume Next
      ''Case 1:  Close: End      '@~@~ was TerminateApp                                                     '!!**
      '23Jun05 TH No Ends allowed !! Need to handle this properly
      End Select

End Sub

Sub Editors(itemnumber%)
'SQL ALL Editors Removed from this Version of software
'''--------------- EDITORS ----------------------------------------------------
'''Derived from Labutils
''
'''21Nov96 CKJ Moved from DOS to Windows
'''            Use for basic files only - not for Warnings or Directions yet
'''             - these call the original DOS programs.
'''            Note also that the ward code editor does not update #wards#.idx
'''            since this is now a stores/supplier file function
''' 2Jan97 CKJ Modified sorting by code/desc to simplify & use column sort
''' 7Jan97 CKJ/NAH Added check for Add Item - couldn't add from empty list
'''14Jan97 CKJ/EAC Modified calls to DOS editors/editdirs - path explicit
'''            Added /SA to the DOS editors calls
'''            Use windows ward editor only if DOS one absent
'''16Jan97 CKJ/EAC added Drug Maintenance at top of list
'''18Mar97 CKJ ShellSortbyColumn replaced with ShellSort
'''11jul97 CKJ added Ethnic Origin editor
''' 5Aug97 CKJ Added ReadOnly view of all items except the direction codes
'''            To use; call the specific view required as a minus number;
'''            eg:   Editors 5       to edit consultant codes
'''                  Editors -5      for read only view of consultant codes
'''15Oct97 CKJ Corrected escape from sort by code/description
'''19Jan98 CKJ Link Cons to directorate expansion now 50 chars to allow list
'''21Jan98 CKJ Added specialty options and revamped the procedure
'''            Corrected prompts when adding a new item after a deletion
'''11Feb97 CKJ added link from Ward to Specialty code
'''05Mar98 CFY Added new parameter to shellsort.
'''16Jul98 CKJ Replication is now offered after every edit, if the file is on the replication list
'''29Sep98 CFY Replaced code which handles the printing. Previously output was spooled to LPT1. Now
'''            output is generated in RTF format and uses context printing.
'''05Oct98 CFY Added extra functionality so that we can now call the directions editor in View-Only mode.
'''17Sep99 AE  Added menu items for presenting complaints and diagnosis codes
'''03Dec99 AW changed ReDim menu$() & menuhlp() to cover new menu items added
'''13Nov98 EAC HK mod to allow addition of items even though user has read-only access
'''20Nov98 CFY Changed functionality of above mod
'''28Jan99 CFY Changed functionality of abovae mod again to prevent editing if RestrictedView is on
'''16Nov00 SF  added prescriber enhancements
'''13jun01 CKJ Change Ethnic Origin caption for Language use
'''11Jan02 TH  Use cut down elements in array for Cons sort if file has > 2000 entries (specific for WA)
'''13Mar02 TH  Large scale changes to allow for two arrays to be used when a file > 2000 entries.(#58364)
'''21May02 SF  allows cancelling out correctly if adding a code (#60922)
'''12sep02 TH  Use intFileLimit instead of hardcoded 2000 records, set to 150 for FFLabels (as this file gets larger quicker)(#63295)
'''12Sep02 TH  Ensure that on sort algorithms the correct file is accessed for the rebuild (not necessarily conscode.dat) (#)
'''12Sep02 TH  Mod to allow for new 'partitioned' file editing of inuse and not inuse (#63323)
'''15Oct02 TH  Added Default file split level (2000 recs) - missed out somehow on last merge (#63295)
'''05Sep02 SF  added pharmacist editors (enh#1274)
'''18May04 CKJ Removed the two part array in preparation for conversion to Heap based handling.
'''19May04 CKJ Heap based storage: three heaps as follows
'''            SortHeap contains <sorted order>,<code>
'''            DataHeap contains <code>,<expansion>
'''            ReindexHeap contains <text to reindex>,<code>
'''
'''            Differences in behaviour from last version:
'''            * Sorting by alpha code or description is now case insensitive
'''            * duplicate codes (NB case insensitive) are treated as the same code
'''            * the duplicate codes are silently binned
'''            * although memory based, this does much more work and is slower
'''            * a blank code may be permitted but is not natively handled, so is treated as "!_"
'''            * sorting by code/description is by alphabetical order on first 30 chars (configurable)
'''            * max items we can handle is 32K, but limit will be reached before this
'''            * neither code nor description can have a tab character, ascii 0, ascii 1
'''            * we check for and remove double quote marks when entering code and description
'''            * the file to edit must already exist on disk
'''
'''            Similar behaviour from last version retained for these items:
'''            * adding a new item always adds at the end, even when sorted by a specific order
'''
'''mods wanted
'''-----------
''' Need to delete FF labels & multiline text - can't see it on screen now
''' Need to limit cut & paste where this would exceed max length for FF label
''' Auto create indexes if not found
'''/allow codes to be deleted
''' Link directorate codes without more files being created
'''/allow codes to be retired - OK for Snow etc but not for general use
''' improve warnings editor
'''/improve instructions editors
''' Would like to add & index safely during the day without closing down
''' Printing to non-existent network printer hangs system under W95
'''
'''-----------------------------------------------------------------------------
''

'11Dec13 TH  Added Patient Invoice editing (TFS 77893)
'22May14 XN  Moved Patient invoice to standard ICW report Editor 88863
'12Jan17 TH  Mods to use DB RTFs rather than files (Hosted)
'18Jul17 TH  Changed log handling to stop test of fileshare. (TFS 184877)

Dim filename$, logging%, ans$, opt$, temp$, fil%, intLin As Integer
Dim Code$, codetype$, codedesc$, codemax%, expmax%, AllowNotInUse%, expdesc$, title$, fullpage%
Dim uppercase%, expans$, ans1$, strLogText As String
Dim change%, menuopt$, FreeFormat%, GPidx%, GPindex$, DeleteItemX%, found&, was$, nowis$, failed%
Dim Char30%, ReadOnly%
Dim intSortHeap As Integer
Dim intDataHeap As Integer
Dim intIndxHeap As Integer
Dim blnHeapOK As Integer
Dim strSeq As String
Dim strSortText As String
Dim Items As Integer
Dim intIndexLength As Integer
Dim blnSuccess As Integer
Dim strParams As String
Dim lngOK As Long
Dim strDisplayName As String
Dim menuhlp() As Integer
Dim strRTFText As String

   ReDim Menu$(8)
   ReDim menuhlp(8)

   'logging = (fileexists(orderlogpath$ & "\*.*"))
   logging = True '18Jul17 TH Replaced above. These editors should now be defunct, but hosted means we cannot use the existence of
   '           areas on the share as semaphores. Set to yes as all logging now SQL anyway. (TFS 184877)

   ReadOnly = (itemnumber < 0)                                   '5Aug97 CKJ Added
   itemnumber = Abs(itemnumber)

   Do
      If itemnumber Then
            ans$ = Format$(itemnumber)                           ' can call any editor directly
         Else
''            Menu$(1) = "Directions"                              'was "Drug Maintenance"
''            Menu$(2) = "Print Directions"
            Menu$(1) = "Warnings"
            Menu$(2) = "Instructions"
            'Menu$(5) = "Consultant codes"
            Menu$(3) = "Supplier, Department and Location codes"
            'Menu$(7) = "GP / Practice codes"
            'Menu$(8) = "Link GP initials to Practice"
            Menu$(4) = "Drug message codes"
            Menu$(5) = "Free Format Label Editor"
            Menu$(6) = "Finance reason codes"
            Menu$(7) = "Patient Information Leaflets"  '14Jan13 TH Added

            Menu$(8) = "Patient Invoice"  '11Dec13 TH Added
            'Menu$(12) = "Directorate codes"
            'Menu$(13) = "Link Ward code to Directorate"
            'Menu$(14) = "Link Consultant to Directorate"         '21Jan98 CKJ returned to original meaning
            'Menu$(15) = "BNF Chapters"
            'Menu$(16) = "BNF Sections"
            'Menu$(17) = "Link Supplier to Ledger code"
            'Menu$(18) = EthnicOrgCaption() & " codes"            '11jul97 CKJ added         '13jun01 CKJ allow 'language codes'
            'Menu$(19) = "Specialty codes"                        '21Jan98 CKJ Added
            'Menu$(20) = "Link Consultant to Specialty"           '   "
            'Menu$(21) = "Link Specialty to Directorate"          '   "
            'Menu$(22) = "Link Ward to Specialty"                 '11Feb97 CKJ added
            'Menu$(23) = "Diagnosis Codes"                        '17Sep99 AE Added
            'Menu$(24) = "Presenting Complaint Codes"             '      "
            'Menu$(25) = "Discharge Letter"
            'Menu$(26) = "Prescriber Editor"                      '16Nov00 SF added
            'Menu$(27) = "Prescriber Type Editor"                 '16Nov00 SF added
            'Menu$(28) = "Pharmacist Editor"                      '05Sep02 SF added (enh#1274)
            'Menu$(29) = "Set Pharmacist In Charge"               '   "
            ans$ = opt$
            inputmenu Menu$(), menuhlp(), ans$, k
         End If
      If k.escd Then Exit Do
      opt$ = ans$

      Select Case opt$
'         Case "1"
'''            If ReadOnly Then
'''                  EditDirections 3                                                                       '05Oct98 CFY Replaced
'''               Else
'''                  EditDirections 1
'''               End If
'
'         Case "2"
'''            EditDirections 2                        'replaces PrintDirections

         Case "1"                                   '13Apr97 CKJ Added block
            ''filename$ = ASCFileName("warning.v4", 1, "")            '14Jul98 CKJ
            filename$ = ASCContextName("warning.v4", 1, "")
            strDisplayName = "Warnings"
            codetype$ = "Warning"
            codedesc$ = "Warning code"
            codemax = 6
            expmax = 135
            FreeFormat = True
            fullpage = True
            Char30 = True
            GoSub editcodes
            Char30 = False
            fullpage = False

         Case "2"
            ''filename$ = ASCFileName("instruct.v4", 1, "")           '14Jul98 CKJ
            strDisplayName = "Instructions"
            filename$ = ASCContextName("instruct.v4", 1, "")
            codetype$ = "Instruction"
            codedesc$ = "Instruction code"
            codemax = 6   '13Mar95 CKJ was 4
            expmax = 35
            GoSub editcodes

''         Case "5"
''            If SlaveModeEnabled() Then                              '10nov03 ckj
''                  popmessagecr "!", "Please configure Consultants in the ICW"    '   "
''               Else
''                  filename$ = dispdata$ & "\conscode.dat"
''                  codetype$ = "Consultant"
''                  codedesc$ = "Consultant / cost centre code"
''                  codemax = 4
''                  expmax = 30
''                  AllowNotInUse = True
''                  GoSub editcodes
''               End If

        Case "3"
            ''Set SupDB = OpenDatabase(dispdata$ & stockmdb$)         '@~@~
            AmendSuppliers Iff(ReadOnly, 1, True), "", k.escd       '5Aug97 CKJ ReadOnly enabled
            On Error Resume Next
            ''SupDB.Close
            On Error GoTo 0

''         Case "7"
''            filename$ = dispdata$ & "\GPcode.dat"
''            codetype$ = "GP / Practice"
''            codedesc$ = "GP / Practice code"
''            codemax = 4
''            expmax = 30
''            AllowNotInUse = True
''            GoSub editcodes

''         Case "8"
''            GPidx = True
''            filename$ = dispdata$ & "\practice.dat"
''            GPindex$ = dispdata$ & "\PRACTICE.IDX"
''            codetype$ = "GP in Practice/Health Centre"
''            codedesc$ = "GP initials"
''            codemax = 4
''            expdesc$ = "Enter practice / health centre"
''            expmax = 4
''            GoSub editcodes
''            binarysearchidx "", "", 0, 0, 0
''            sortindex "", GPindex$
''            GPidx = False

         Case "4"                                  '16Mar94 CKJ Added
            title$ = "Drug Message Editor"
            strDisplayName = "Drug Messages"
            FreeFormat = False
            'filename$ = dispdata$ & "\usermsg.dat"
            filename$ = "usermsg"
            codetype$ = "Message"
            codedesc$ = "Drug message code"
            codemax = 2
            fullpage = True    '13Mar95 CKJ
            GoSub editcodes
            fullpage = False

         Case "5"                                   '26Mar94 ASC Added
            title$ = "Free Format Label Editor"
            strDisplayName = "Free Format Labels"
            FreeFormat = True
            'filename$ = dispdata$ & "\fflabels.dat"
            filename$ = "fflabels"
            'intFileLimit = 150         '12sep02 TH Added          ** May still want an artificial limit here '##
            codetype$ = "Label"
            codedesc$ = "Label code"
            codemax = 3
            fullpage = True
            GoSub editcodes
            fullpage = False

         Case "6"
            filename$ = "reason"
            'filename$ = dispdata$ & "\reason.dat"
            strDisplayName = "Reasons"

            codetype$ = "Reason for action"
            codedesc$ = "Finance reason code"
            codemax = 2
            expmax = 30
            GoSub editcodes

         Case "7"
          CallEditPILS (Not ReadOnly)
          
         Case "8"
            ' Moved Patient invoice to standard ICW report Editor 22May14 XN 88863
            If Not TrueFalse(TxtD(dispdata$ & "\PATBILL.INI", "TranBill", "N", "UseOldPatientInvoice", 0)) Then
               'If Not fileexists(dispdata$ & "\Invoice.rtf") Then
               If Not RTFExistsInDatabase(dispdata$ & "\Invoice.rtf") Then '12Jan17 TH Replaced Above(Hosted)
                  popmessagecr "#", "Patient Invoicing not enabled."
               Else
                  If Not ReadOnly Then
                     'Hedit 11, dispdata$ & "\Invoice.rtf"
                     EditRTFFromDB dispdata$ & "\Invoice.rtf"  '12Jan17 TH Replaced Above(Hosted)
                  Else
                     'Hedit 10, dispdata$ & "\Invoice.rtf"
                     strRTFText = getPharmacyRTFfromSQL(dispdata$, "Invoice.RTF")   '12Jan17 TH Replaced Above(Hosted)
                     Hedit 0, strRTFText                                            '  "
                  End If
               End If
            Else
               MsgBox "Use the standard Report Editor (Under report Types - Stand-alone report description Pharmacy Patient Invoice <Site Number>)"
            End If
         
         Case "12"
''            filename$ = dispdata$ & "\dirctrte.dat"
''            codetype$ = "Directorate"
''            codedesc$ = "Directorate code"
''            codemax = 4
''            expmax = 20
''            GoSub editcodes

         Case "13"
''            filename$ = dispdata$ & "\warddir.dat"
''            codetype$ = "Ward/Directorate"
''            codedesc$ = "Link Ward code to Directorate"
''            expdesc$ = "Enter directorate code"
''            codemax = 4
''            expmax = 4
''            uppercase = True
''            GoSub editcodes

         Case "14"
''            filename$ = dispdata$ & "\consdir.dat"
''            codetype$ = "Consultant/Directorate"
''            codedesc$ = "Link Consultant to Directorate"
''            expdesc$ = "Enter directorate code"
''            codemax = 4
''            expmax = 4
''            uppercase = True
''            GoSub editcodes

         Case "15"
''            filename$ = dispdata$ & "\bnfchap.dat"
''            codetype$ = "BNF chapter"
''            codedesc$ = "BNF chapter"
''            codemax = 2
''            expmax = 50
''            GoSub editcodes

         Case "16"
''            filename$ = dispdata$ & "\bnfsect.dat"
''            codetype$ = "BNF section"
''            codedesc$ = "BNF section"
''            codemax = 5
''            expmax = 50
''            GoSub editcodes

         Case "17"
''            filename$ = dispdata$ & "\ledgcode.dat"
''            codetype$ = "Supplier/Ledger"
''            codedesc$ = "Link Supplier to Ledger"
''            codemax = 5
''            expmax = 50
''            GoSub editcodes

         Case "18"
''            filename$ = dispdata$ & "\ethncode.dat"
''            codetype$ = EthnicOrgCaption()                       '13jun01 CKJ allow 'language codes'
''            codedesc$ = codetype$ & " code"                      '   "
''            codemax = 4
''            expmax = 30
''            GoSub editcodes

         Case "19"
''            filename$ = dispdata$ & "\speclty.dat"
''            codetype$ = "Specialty"
''            codedesc$ = "Specialty code"
''            codemax = 4
''            expmax = 20
''            GoSub editcodes

         Case "20"
''            filename$ = dispdata$ & "\consspec.dat"
''            codetype$ = "Consultant/Specialty"
''            codedesc$ = "Link Consultant to Specialty"
''            expdesc$ = "Enter Specialty code(s), separated by commas without any spaces."
''            codemax = 4
''            expmax = 50
''            uppercase = True
''            GoSub editcodes

         Case "21"
''            filename$ = dispdata$ & "\specdrct.dat"
''            codetype$ = "Specialty/Directorate"
''            codedesc$ = "Link Specialty to Directorate"
''            expdesc$ = "Enter Directorate code"
''            codemax = 4
''            expmax = 4
''            uppercase = True
''            GoSub editcodes

         Case "22"                                          '11Feb97 CKJ added
''            filename$ = dispdata$ & "\wardspec.dat"
''            codetype$ = "Ward/Specialty"
''            codedesc$ = "Link Ward to Specialty"
''            expdesc$ = "Enter Specialty code"
''            codemax = 4
''            expmax = 4
''            uppercase = True
''            GoSub editcodes

         Case "23"    'diagnosis                            '17Sep99 AE added
''            DischargeEditors 1                              '22Sep99 AE Replaced  'EditCodesDB "Diagnose", "Diagnosis"

         Case "24"    'Presenting complaints                '17Sep99 AE added
''            DischargeEditors 2                              '22Sep99 AE Replaced  'EditCodesDB "Presenting", "Presenting Complaint"

         Case "25"
''            DischargeEditors 3                              '22Sep99 AE Replaced 'EditDischarge'

         Case "26"                  ' Prescriber details    '16Nov00 SF added
''            RxEditor 2, ReadOnly

         Case "27"
''            RxEditor 1, ReadOnly    ' Prescriber types      '16Nov00 SF added

         Case "28"                                          '05Sep02 SF added
''            PharmacistEditor ReadOnly

         Case "29"                                          '05Sep02 SF added
''            PharmacistInCharge ReadOnly
         Case Else
         End Select
   Loop While itemnumber = 0

   Unload LstBoxFrm
   k.escd = False

Exit Sub


editcodes:
   Heap 1, intSortHeap, "Editors - Sort Order", "", blnHeapOK
   If blnHeapOK Then Heap 1, intDataHeap, "Editors - Data", "", blnHeapOK
   If Not blnHeapOK Then
      popmessagecr "!", "Cannot allocate enough memory"
      Return
   End If

   If Not EditorsReadFile(intSortHeap, intDataHeap, filename, Char30, strDisplayName) Then
      Return
   End If

   Do
      Screen.MousePointer = HOURGLASS

      popmenu 0, "", 0, 0
      popmenu 2, "&Edit Item[cr]&Print list", 0, 0
      If Not ReadOnly Then                                                                                           '20Nov98 CFY
         If RestrictedView() Then                                                                                 '      "
            popmenu 1, "&Add Item", False, False
            popmenu 1, "De&lete Item", False, False
            popmenu 1, "Sort by &Code", True, False
            popmenu 1, "Sort by &Description", True, False
         Else                                                                                                  '      "
            popmenu 2, "&Add Item[cr]De&lete item[cr]Sort by &Code[cr]Sort by &Description", 0, 0              '      "
            'popmenu 2, "&Add Item[cr]De&lete item", 0, 0              '      "
         End If                                                                                                '      "
      End If                                                                                                      '      "

      Unload LstBoxFrm
      LstBoxFrm.Caption = codedesc$
      LstBoxFrm.lblTitle = cr & "Select item to edit." & cr & "Press Shift-F1 or click right mouse button for menu" & cr
      LstBoxFrm.lblHead = "  Code    " & TB & codetype$ & Space$(30)
      If AllowNotInUse Then
         LstBoxFrm.lblHead = LstBoxFrm.lblHead & TB & "In use"
         If Not ReadOnly Then popmenu 2, "Set to &In use[cr]Set to &Not in use", 0, 0
      End If

      strSeq = ""
      Do
         Code = ""
         Heap 13, intSortHeap, strSeq, Code$, blnHeapOK                  ' 13  Read next item from sort heap
         If blnHeapOK Then
            Heap 11, intDataHeap, Code$, expans$, blnHeapOK           ' 11  Read item from data heap
         End If
         If blnHeapOK Then
               temp$ = ""
               If AllowNotInUse Then
                     temp$ = TB & YesNo$(InStr(expans$, "#") = 0)
                  End If
               temp$ = expans$ & temp$
               replace temp$, crlf, " ", 0
               LstBoxFrm.LstBox.AddItem "  " & Code$ & TB & Trim$(temp$)
            End If
      Loop While blnHeapOK

      On Error Resume Next
      LstBoxFrm.LstBox.ListIndex = intLin - 1
      On Error GoTo 0
      ans$ = ""
      strSortText = ""
      Screen.MousePointer = STDCURSOR

      LstBoxShow

      popmenu 0, "", 0, 0
      menuopt$ = LstBoxFrm.LstBox.Tag
      intLin = 0
      If LstBoxFrm.Tag <> "" Then                     'a line was selected and it was not blank
            intLin = LstBoxFrm.LstBox.ListIndex + 1   '0 to n-1 => 1 to n

            temp$ = LstBoxFrm.Tag
            replace temp$, TB, Nul, 0                                                'replace tab with nul
            Code$ = Trim$(asciiz(temp$))                                             'and truncate at the nul
            Heap 11, intDataHeap, Code$, expans$, blnHeapOK                          'read heap

            If Not EditorsFindSortTextFromCode(intSortHeap, Code$, strSortText) Then 'try to find the item
                  popmessagecr ".", "Editors: SortText not found in Sort Heap. Please inform Support"    'should be impossible so test for it anyway
                  Exit Do
               End If
         Else                                         'no line selected
            If menuopt$ <> "3" Then Exit Do           'didn't choose 'Add' so it's time to exit
         End If

      LstBoxFrm.Show 0
      LstBoxFrm.Enabled = False

      If menuopt$ = "3" Then 'Add new item - type code then enter description
            ans$ = ""
            k.min = 1
            k.Max = codemax
            InputWin "New Code", "Enter new " & codetype$ & " code", ans$, k
            If InStr(ans$, Chr$(34)) Then                                                   '20May04 CKJ added block
                  popmessagecr "!", "Double quotation marks are not permitted"
                  k.escd = True
               End If

            If Not k.escd Then    '13Mar95 CKJ Added k.escd
                  Code$ = Trim$(UCase$(ans$))
                  expans$ = ""
                  Heap 11, intDataHeap, Code$, expans$, blnHeapOK                           'read heap
                  If Not EditorsFindSortTextFromCode(intSortHeap, Code$, strSortText) Then  'try to find the item
                        'not found, so ensure it will go at the end of the file, if saved later
                        temp$ = "00000"                                                     'in case heap is empty
                        Heap 14, intSortHeap, temp$, "", blnHeapOK                          'find key to last item
                        strSortText = Format$(Val(temp$) + 1, "00000")
                     End If
                  menuopt$ = "1"                                                            'proceed to description editor
               End If
         End If

      Select Case menuopt$
         Case "", "1"           ' Return key, menu 1 or menu 3 - edit existing item, or Add description to new item
            ans1$ = expans$
            If fullpage Then
                  change = Iff(ReadOnly Or RestrictedView(), False, True)                   '20Nov98 CFY
                  TextEdit title$, ans1$, codetype$ & ":  " & Code$, change, FreeFormat
               Else
                  If Len(expdesc$) Then
                        temp$ = expdesc$
                     Else
                        temp$ = "Enter description for code '" & Code$ & "'"
                     End If
                  If ReadOnly Or RestrictedView() Then                  '     "
                        popmessagecr "EMIS Health", codedesc$ & " '" & Code$ & "'" & cr & cr & ans1$
                     Else
                        k.min = 1
                        k.Max = expmax
                        'k.helpnum = 60
                        InputWin codedesc$, temp$, ans1$, k
                        If InStr(ans1$, Chr$(34)) Then                                      '20May04 CKJ added block
                              popmessagecr "!", "Double quotation marks are not permitted"
                              k.escd = True
                           End If
                     End If
               End If

            If Not k.escd And Not (ReadOnly Or RestrictedView()) Then
                  If GPidx Then GoSub GPindex                             '##
                  If uppercase Then ans1$ = UCase$(ans1$)
                  If ans1$ <> expans$ Then
                        Heap 10, intDataHeap, Code$, ans1$, blnHeapOK                             'Write CODE=Expansion
                        Heap 10, intSortHeap, strSortText, Code$, blnHeapOK                       'Write SORT=CODE
                        strLogText = Code$ & "," & expans$ & "," & ans1$
                        ''GoSub savefile
                        'Just save the new expansion here
                        'Check for inuse or not
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("Context", trnDataTypeVarChar, 255, filename) & _
                                    gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 10, Code$) & _
                                    gTransport.CreateInputParameterXML("Value", trnDataTypeVarChar, 1024, ans1$) & _
                                    gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, 1)
                        lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLookupWriteValuebyCode", strParams)
                     End If
               End If
            k.escd = False

         Case "2" ' F2 Print all
            EditorsPrintAll intSortHeap, intDataHeap, codedesc$

         Case "4" '  Delete item
            ans$ = "N"
            'k.helpnum = 90
            askwin "?Delete Code", "OK to delete code '" & Trim(Code$) & "'?" & cr & cr & Trim(expans$), ans$, k
            If ans$ = "Y" And Not k.escd Then
                  Heap 12, intDataHeap, Code$, "", blnHeapOK
                  If EditorsFindSortTextFromCode(intSortHeap, Code$, strSortText) Then
                        Heap 12, intSortHeap, strSortText, "", blnHeapOK
                     End If

                  strLogText = Code$ & "," & expans$ & ",<Deleted>"
                  'GoSub savefile
                  'Delete the record here ???
                  strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                              gTransport.CreateInputParameterXML("Context", trnDataTypeVarChar, 255, filename) & _
                              gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 10, Code$)
                  lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLookupDeletebyCode", strParams)
                  'popmessagecr "Editors", "Delete Record here"
                  '''DeleteItemX = True
                  '''If GPidx Then GoSub GPindex                 '##
                  '''DeleteItemX = False
               End If

         Case "5"              'Sort by code
            'The DataHeap is <code>,<description> so simply dumping the SortHeap and refilling does the job
            ans$ = "Y"
            Confirm "?Sort by Code", "save the file sorted by code", ans$, k
            If ans$ = "Y" And Not k.escd Then
                  Screen.MousePointer = HOURGLASS
                  '05Dec05 TH
                  WritePrivateIniFile "LookupSortby", filename$, "Code", dispdata$ & "\ascribe.ini", 0
                  blnSuccess = True                          'only gets set false if handling the heap fails - a serious error
                  Heap 2, intSortHeap, "", "", blnSuccess                                               'dump the sort heap
                  If blnSuccess Then Heap 1, intSortHeap, "Editors - Sort Order", "", blnSuccess        'recreate it
                  If blnSuccess Then
                        Items = 0
                        Code = ""
                        Do
                           Heap 13, intDataHeap, Code$, "", blnHeapOK                                   ' 13  Read next item from data heap
                           If blnHeapOK Then
                                 Items = Items + 1
                                 Heap 10, intSortHeap, Format$(Items, "00000"), Code$, blnSuccess 'write 00001,CODE to sort heap
                              End If
                        Loop While blnHeapOK And blnSuccess
                     End If

                  Screen.MousePointer = STDCURSOR
                  If blnSuccess Then
                        strLogText = "<Sorted by Code>"
                        GoSub savefile
                     Else
                        popmessagecr ".", "Insufficient memory to sort. No changes made"
                        Exit Do
                     End If
               End If

         Case "6"              'Sort by description
            'The DataHeap is <code>,<description> so copying into a temporary heap <truncated description,sequence number>,<code>
            'then copying the new sequence and code into a fresh sort heap is fairly efficient
            ans$ = "Y"
            Confirm "?Sort by Description", "save the file sorted by description", ans$, k
            If ans$ = "Y" And Not k.escd Then
                  Screen.MousePointer = HOURGLASS
                  '05Dec05 TH
                  WritePrivateIniFile "LookupSortby", filename$, "Value", dispdata$ & "\ascribe.ini", 0
                  blnSuccess = True                          'only gets set false if handling one of the heaps fails - a serious error
                  Heap 1, intIndxHeap, "Editors - Reindex", "", blnSuccess                              'create temp reindex heap
                  If blnSuccess Then
                        intIndexLength = Val(TxtD(dispdata$ & "\stkmaint.ini", "Editors", "30", "IndexLength", False))
                        Items = 0
                        Code = ""
                        Do
                           expans$ = ""
                           Heap 13, intDataHeap, Code$, expans$, blnHeapOK                              ' 13  Read next item from data heap
                           If blnHeapOK Then
                                 Items = Items + 1
                                 expans$ = UCase$(Left$(expans$, intIndexLength)) & Format$(Items, "00000") '<DESCRIP00001>,<CODE>
                                 Heap 10, intIndxHeap, expans$, Code$, blnSuccess                           'write to Index heap
                              End If
                        Loop While blnHeapOK And blnSuccess

                        If blnSuccess Then Heap 2, intSortHeap, "", "", blnSuccess                      'dump the sort heap
                        If blnSuccess Then Heap 1, intSortHeap, "Editors - Sort Order", "", blnSuccess  'recreate it
                        If blnSuccess Then                                                              'transfer from Index to Sort heap
                              Items = 0
                              Code = ""
                              Do
                                 expans$ = ""
                                 Heap 13, intIndxHeap, Code$, expans$, blnHeapOK                        ' 13  Read next item from sort heap
                                 If blnHeapOK Then
                                       Items = Items + 1
                                       Heap 10, intSortHeap, Format$(Items, "00000"), expans$, blnSuccess   'write 00001,CODE to sort heap
                                    End If
                              Loop While blnHeapOK And blnSuccess
                           End If

                        Heap 2, intIndxHeap, "", "", blnHeapOK                                          'dump the index heap
                     End If

                  Screen.MousePointer = STDCURSOR
                  If blnSuccess Then
                        strLogText = "<Sorted by Expansion>"
                        GoSub savefile
                     Else
                        popmessagecr ".", "Insufficient memory to sort. No changes made"
                        Exit Do
                     End If
               End If

         Case "7" 'set to in use
            If InStr(expans$, "#") Then
                  replace expans$, "#", "", 0
                  Heap 10, intDataHeap, Code$, expans$, blnHeapOK               ' 10  Write to a heap.
                  strLogText = Code$ & "," & expans$ & ",<Set In Use>"
                  GoSub savefile
               End If

         Case "8" 'set to not in use
            If InStr(expans$, "#") = 0 Then
                  expans$ = Left$("#" & expans$, expmax)
                  Heap 10, intDataHeap, Code$, expans$, blnHeapOK               ' 10  Write to a heap.
                  strLogText = Code$ & "," & expans$ & ",<Set Not In Use>"
                  GoSub savefile
               End If

         End Select
      LstBoxFrm.Enabled = True
      LstBoxFrm.Hide
   Loop

   expdesc$ = ""       '28Feb95 CKJ
   uppercase = False
   AllowNotInUse = False

   Heap 2, intSortHeap, "", "", blnHeapOK                                       'destroy heaps
   Heap 2, intDataHeap, "", "", blnHeapOK
Return


savefile:
   If EditorsSaveFile(intSortHeap, intDataHeap, filename, Char30, codemax) Then
''         If fileexists(dispdata$ & "\PushCtrl.ini") Then                    '16Jul98 CKJ Replication
''               ManualPush filename
''            End If
      Else
         strLogText = strLogText & ",<**Unable To Save File**>"
      End If
   If logging Then
         WriteLog dispdata$ & "\EDITORS.LOG", SiteNumber, UserID$, Left$(codedesc$, 11) & "," & strLogText
      End If
Return


GPindex:                                            '##
''   If Not fileexists(GPindex$) Then
''         fil = FreeFile
''         Open GPindex$ For Output As #fil
''         Print #fil, "8"; Space$(7); "000000"; cr;
''         Print #fil, Space$(8); "000000"; cr;
''         Close fil
''      End If
''
''   temp$ = code$
''   binarysearchidx temp$, GPindex$, 1, 0, found&
''   If found& Then was$ = temp$ Else was$ = ""
''
''   ans1$ = Trim(UCase$(ans1$))                    'return ans1$ as ucase
''   nowis$ = Left$(code$ & "    ", 4) & ans1$
''   If DeleteItemX Then nowis$ = ""                    '13Feb95 CKJ added
''   If was$ <> nowis$ Then
''         Updateindex was$, nowis$, 1, GPindex$, failed
''      End If
''
''   '!!** no trapping of failed update yet
''   'popmessagecr was$, STR$(failed)
Return


End Sub

Private Function EditorsReadFile(ByVal intSortHeap As Integer, ByVal intDataHeap As Integer, ByVal strFilename As String, ByVal Char30 As Integer, ByVal strDisplayName As String) As Integer
'SQL Editor functions removed from this version of software
'''19May04 CKJ written
'''            Only used by editors procedure
'''            Requires initialised empty heaps and a fully qualified pathfilename
'''            If code is blank then replace with '!_' during editing
'''            If Char30 is True then Chr$(30) is replaced with CRLF
'''            Note that duplicate codes will retain the LAST of the duplicates
'''            Returns Success T/F
''
'28Sep05 TH REinstated and converted to SQL

Dim Items As Integer
Dim i As Integer
Dim ErrNum As Integer
Dim fil As Integer
Dim Code As String, expans As String
Dim blnHeapOK As Integer
Dim success As Integer
Dim strParameters As String
Dim rsLookups As ADODB.Recordset


   success = False
   Screen.MousePointer = HOURGLASS
   
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, strFilename) & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 10, Null) & _
                   gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, Null)

   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParameters)

   'If fileexists(strFilename) Then
   If rsLookups.RecordCount > 0 Then
   
''         Do
''            On Error GoTo EditorsReadFile_Err
''            ErrNum = 0
''            fil = FreeFile
''            Open filename$ For Input As #fil
''            Err70msg ErrNum, "File " & filename$
''         Loop While ErrNum
''         On Error GoTo 0
''
''         Input #fil, items

         ''For i = 1 To items
         rsLookups.Sort = "Code" '(#83614)
         rsLookups.MoveFirst
         i = 1
         Do While Not rsLookups.EOF
         
            'Input #fil, Code$, expans$
            Code$ = RtrimGetField(rsLookups!Code)
            expans$ = RtrimGetField(rsLookups!Value)
            Code$ = UCase$(Trim$(Code$))
            If Code$ = "" Then Code$ = "!_"
            expans$ = RTrim$(expans$)
            If Char30 Then replace expans$, Chr$(30), crlf, 0

            Heap 11, intDataHeap, Code$, "", blnHeapOK                                'Read CODE
            If Not blnHeapOK Then                                                     'not already stored
                  Heap 10, intDataHeap, Code$, expans$, blnHeapOK                     'CODE=Expansion
                  If blnHeapOK Then
                        Heap 10, intSortHeap, Format$(i, "00000"), Code$, blnHeapOK   '00001=CODE
                        i = i + 1
                     End If
                  If Not blnHeapOK Then Exit Do
               End If
         'Next
            rsLookups.MoveNext
         Loop
         'Close #fil
     Else
         Screen.MousePointer = STDCURSOR
         popmessagecr "Editors", "There are no records for " & strDisplayName
     End If
         
         
      
      rsLookups.Close
      Set rsLookups = Nothing
   If blnHeapOK Then success = True

EditorsReadFile_Exit:
   EditorsReadFile = success
   Screen.MousePointer = STDCURSOR

Exit Function

EditorsReadFile_Err:
   Select Case Err
      Case 70, 63
         ErrNum = Err
         Resume Next
      End Select
   popmessagecr "!Procedure halted", " Error " & Format$(Err) & " while Accessing " & strFilename & crlf & Error$
Resume EditorsReadFile_Exit

End Function
Private Function EditorsSaveFile(ByVal intSortHeap As Integer, ByVal intDataHeap As Integer, ByVal filename As String, ByVal Char30 As Integer, ByVal codemax As Integer) As Integer
'SQL Editor functions removed from this version of software
'''20May04 CKJ written
'''            Only used by the Editors procedure
'''            Requires initialised heaps and a fully qualified pathfilename
'''            If code is '!_' then replace with blank
'''            If Char30 is True then CRLF is replaced with Chr$(30)
'''            codemax is the maximum num of chars for the code
'''            Returns Success T/F
''
''Dim items As Integer
''Dim strSeq As String
'''Dim i As Integer
''Dim ErrNum As Integer
''Dim fil As Integer
''Dim Code As String, expans As String
''Dim blnHeapOK As Integer
''Dim success As Integer
''
''   Screen.MousePointer = HOURGLASS
''   success = False
''   items = 0
''   strSeq = ""
''   Do
''      Heap 13, intSortHeap, strSeq, "", blnHeapOK                           ' 13  Read next item from sort heap
''      If blnHeapOK Then items = items + 1
''   Loop While blnHeapOK
''
''   Do
''      On Error GoTo EditorsSaveFile_Err
''      ErrNum = 0
''      fil = FreeFile
''      Open filename$ For Output As #fil
''      Err70msg ErrNum, "File " & filename$
''   Loop While ErrNum
''   On Error GoTo 0
''   Print #fil, Format$(items)             'Number of items in file
''
''   strSeq = ""
''   Do
''      Code$ = ""
''      Heap 13, intSortHeap, strSeq, Code$, blnHeapOK                  ' 13  Read next item from sort heap
''      If blnHeapOK Then
''            Heap 11, intDataHeap, Code$, expans$, blnHeapOK           ' 11  Read item from data heap
''         End If
''      If blnHeapOK Then
''            If Code$ = "!_" Then Code$ = ""
''            expans$ = RTrim$(expans$)
''            If Char30 Then replace expans$, crlf, Chr$(30), 0
''            Write #fil, Left$(Code$ & Space$(codemax), codemax), expans$
''         End If
''   Loop While blnHeapOK
''
''   Close #fil
''   success = True
''   Screen.MousePointer = STDCURSOR
''
''EditorsSaveFile_Exit:
''   EditorsSaveFile = success
''
''Exit Function
''
''EditorsSaveFile_Err:
''   Select Case Err
''      Case 70, 63
''         ErrNum = Err
''         Resume Next
''      End Select
''   Screen.MousePointer = STDCURSOR
''   popmessagecr "!Procedure halted", " Error " & Format$(Err) & " while saving file " & filename$ & crlf & Error$
''Resume EditorsSaveFile_Exit
''
End Function

Private Sub EditorsPrintAll(ByVal intSortHeap As Integer, ByVal intDataHeap As Integer, ByVal codedesc$)
'SQL Editor functions removed from this version of software
'19May04 CKJ written
'            Only used by Editors procedure
'            Requires initialised Editors Heaps and Print Heap
'04Jan17 TH  Use DB Parsing (Hosted)
'07Jan17 TH  Refactored RTF check to DB (Hosted)
'26Jan17 TH  Use new RTFExistsinDatabase function to avoid superfluous msg (TFS 174442)

Dim fil As Integer
Dim TmpFile1$
Dim strSeq As String
Dim Code$, expans$
Dim blnHeapOK  As Integer
Dim intSuccess As Integer '08Jan17 TH Added (Hosted)

   'If fileexists(dispdata$ & "\lstprint.rtf") Then
   'GetRTFTextFromDB dispdata$ & "\lstprint.rtf", "", intSuccess '07Jan17 TH Moved check to DB (Hosted)
   'If intSuccess Then
   If RTFExistsInDatabase(dispdata$ & "\lstprint.rtf") Then  '26Jan17 TH Replaced above
   
         Heap 10, gPRNheapID, "ReportTitle", codedesc$, 0
         Heap 10, gPRNheapID, "InternalTitle", codedesc$, 0
         Heap 10, gPRNheapID, "ColumnTitles", "Code" & " \tab " & "Expansion", 0

         MakeLocalFile TmpFile1$
         fil = FreeFile
         Open TmpFile1$ For Output As #fil

         strSeq = ""
         Do
            Code$ = ""
            Heap 13, intSortHeap, strSeq, Code$, blnHeapOK                  ' 13  Read next item from sort heap
            If blnHeapOK Then
                  Heap 11, intDataHeap, Code$, expans$, blnHeapOK           ' 11  Read item from data heap
               End If
            If blnHeapOK Then
                  If Code$ = "!_" Then Code$ = ""
                  Print #fil, Code$ & " \tab " & expans$
                  Print #fil, " \par "
               End If
         Loop While blnHeapOK

         Close #fil

         Heap 10, gPRNheapID, "ColumnData", "[#include" & TB & TmpFile1$ & "]", 0
         'ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False '15Jun11 TH Added parameter (F0088129)
         ParseThenPrint "SysMaint", dispdata$ & "\lstprint.rtf", 1, 0, False, False '04Jan17 TH Use DB Parsing (Hosted)

         On Error Resume Next
         Kill TmpFile1$
         On Error GoTo 0
      Else
         'popmessagecr "!", "Could not print list. File '" & dispdata$ & "\lstprint.rtf' not found."
         popmessagecr "!", "Could not print list. RTF 'lstprint' not found in database."
      End If


End Sub

Private Function EditorsFindSortTextFromCode(ByVal intSortHeap As Integer, ByVal strCode As String, strSortText As String) As Integer
'SQL Editor functions removed from this version of software
'''19May04 CKJ written
'''            Only used from Editors procedure
'''            Given Code$, look it up in the sortHeap to find the associated SortText
'''            If found, return success True and the SortText
'''            If not found then return SortText="" and False
'''            Uses the editors SortHeap which must be initialised but can be empty
''
Dim blnFoundItem As Integer
Dim blnSuccess As Integer
Dim strSequence As String
Dim tmpCode As String

   blnFoundItem = False
   strSortText = ""
   strSequence = ""

   Do
      tmpCode = ""
      Heap 13, intSortHeap, strSequence, tmpCode, blnSuccess             ' 13  Read next item from sort heap
      If blnSuccess Then                                                 'found a line
            If tmpCode = strCode Then                                    'found the line we want
                  strSortText = strSequence                              'keep the Sequence code
                  blnFoundItem = True
                  Exit Do
               End If
         End If
   Loop While blnSuccess

   EditorsFindSortTextFromCode = blnFoundItem

End Function
Sub SetWardSpecifics(ListEnabled%, WardEnabled%, StoreEnabled%)
'SQL REMOVED
'07Oct05 TH Reinstated
Dim i%

   For i = 1 To Val(Ques.F3D1.Tag)                     ' 1 to Number of controls created
      Select Case Val(Ques.lblDesc(i).Tag)             'reference number of line
         Case 14                                       'supplier specific data (contract)
            Ques.lblDesc(i).Enabled = Not WardEnabled
            Ques.cmdQ(i).Enabled = Not WardEnabled
            Ques.lblInfo(i).Enabled = Not WardEnabled
         Case 22, 23, 25                               'supplier specific data
            Ques.lblDesc(i).Enabled = Not WardEnabled
            Ques.txtQ(i).Enabled = Not WardEnabled
            Ques.lblInfo(i).Enabled = Not WardEnabled
         Case 29                                       'Ward code for linking to list
            Ques.lblDesc(i).Enabled = ListEnabled
            Ques.txtQ(i).Enabled = ListEnabled
            Ques.lblInfo(i).Enabled = ListEnabled
         Case 30, 32 To 35                             'Ward specific topup data
            Ques.lblDesc(i).Enabled = WardEnabled
            Ques.txtQ(i).Enabled = WardEnabled
            Ques.lblInfo(i).Enabled = WardEnabled
         Case 31                                                    '09Oct00 THMake Delivery note option turnoffable for store
            Ques.lblDesc(i).Enabled = WardEnabled Or StoreEnabled
            Ques.txtQ(i).Enabled = WardEnabled Or StoreEnabled
            Ques.lblInfo(i).Enabled = WardEnabled Or StoreEnabled
      End Select
   Next

End Sub
Sub CallEditPILS(ByVal FullAccess As Boolean)
'26Jan17 TH Replacement for PIL Enabling

   'If Not fileexists(dispdata$ & "\pil\*.pil") Then
   If Not PILRTFsExistInDatabase() Then   '26Jan17 TH Replacement for above - HOSTED
      popmessagecr "#", "Patient Information Leaflets not enabled."
   Else
      If FullAccess Then
         EditFiles dispdata$ & "\pil", "pil", "Patient Information Leaflets", 1, ""             '23Sep99 CFY Added
      Else
         EditFiles dispdata$ & "\pil", "pil", "Patient Information Leaflets", 2, ""
      End If
   End If
   
End Sub
Private Function PILRTFsExistInDatabase() As Boolean
'27Jan17 TH Written for Hosted Enhancements to see if PILS enabled

Dim strParams As String
Dim lErrNo As Long
Dim sErrDesc As String
Dim lngResult As Long

   On Error GoTo ErrorHandler
   
   lngResult = 0
      
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPharmacyPILRTFExistsbySite", strParams)
   
   
   PILRTFsExistInDatabase = (lngResult = 1)
   
Cleanup:
      
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, "RTFExistsInDatabase", sErrDesc
   End If
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup
End Function

