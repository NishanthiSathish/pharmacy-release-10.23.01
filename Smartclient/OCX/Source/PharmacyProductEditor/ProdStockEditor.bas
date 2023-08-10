Attribute VB_Name = "ProdStockEditor"

'30Sep08 CKJ Checkdrug: prevent zero d/m/y in start of period (F0024926)
'01oct08 CKJ Checkdrug: prevent zero in pack size (merged from V8)  (F0029065)
'08oct08 CKJ StkMaint_Callback: DisplayBNFsectionlist replaces displaymacrofile
'22oct08 AK  ViewSelected: Pass read only field array from settings for DSS Maintained products (F0018781)

'RCN P009

'20Mar09 TH  Stockoutput: Written for UHB SAGE Interface solution (F0032689)
'20Mar09 TH  ViewSelected: Added mods for UHB stock interface (F0032689)
'07Apr10 AJK ArrayToStruct: New fields ported from v8 for F0072782 and F0072542
'07Apr10 AJK StructToArray: New fields ported from v8 for F0072782 and F0072542
'14Apr10 AJK ArrayToStruct: Added fields for F0072782
'14Apr10 AJK StructToArray: Added fields for F0072782
'14Apr10 AJK CheckDrug F0042865 Added check for "-" being entered and cleaned up cost validation
'20Apr10 AJK F0077124 Added NSV checks and rsCheck tidyup
'17May10 AJK F0076258 ReadLocalSites: Removed doneonce check as values are persisting across different controls in ICW
'10Jun10 XN  ViewSelected: Got it to use DSSUpdateServiceInUse instead of the DSSMaster flag, and ProductID <> 0 instead of InUse<>"S" (F0088717)
'26Aug10 AJK Checkdrug: F0042865 Added extra cost validation checks
'02Nov10 AJK ViewSelected: F0086901 Added paydate to OrderLog calls

'12Jul12 CKJ Added Robot Product Information
'17Jul12 CKJ Removed SelectView as it was an unused, out of date, partial copy of the one in PSE.ctl

'13Jun13 TH  StructToArray: Added ExpiryWarnDays (TFS 39884)
'13Jun13 TH  ArrayToStruct: Added ExpiryWarnDays (TFS 39884)
'09Oct13 XN  ViewSelected: Config setting to allow certain sites to edit a drug if they are on DSSOnWeb (TFS 75466)
'15Nov13 XN  ViewSelected: Moved labutils.log to WPharmacyLog table 56701

Option Explicit
DefInt A-Z

'Global Const PROJECT = "Product Stock Editor"

Const OBJNAME = "ProductStockEditor.Bas"

Enum ControlStateEnum
   Uninitialised = 0
   InitialisedBlank = 1
End Enum

''Global DispenseState As ControlStateEnum
'Global ConstrainedProductList As Boolean

'15Aug12 CKJ Changed type to object for gTransport so it can be either transport layer   TFS36929
'Global gTransport As PharmacyData.Transport
Global gTransport As Object
   
Global UserControlIsAlive As Integer
Global g_SessionID As Long
Global gEntityID_User As Long    'Currently logged in user
''Global VAT(0 To 9) As Single
Global TransLogVAT%
Global OrderLogVAT%
Global Highfact!
Global Lowfact!
Global entercostonreceipt$
Global tofollow%
Global UtilOrdNum$
Global UtilSupplier$
Global UtilReasonNew$
Global UtilReasonMod$
Global presentent$()
Dim contpriceperc!
Global gRequestID_Prescription As Long
Global gRequestID_Dispensing As Long
Global gProductID As Long
Global lngProductStockID As Long
Global blnAMPP As Boolean
Global blnTM As Boolean
Global blnNMP As Boolean
Global blnStoresOnly As Boolean '13Feb06 TH Added
Global g_strTMDescription As String
Global sup As supplierstruct '10Oct06 TH Added
Global sitenos() As Integer                                      '22Apr07 TH Added
Global siteabb$(), sitepth$()
Global localsitenos() As Integer                                      '22Apr07 TH Added
Global localsiteabb$(), localsitepth$()

Dim m_UCHWnd As Long    '12Jul12 CKJ For mechdisp
'
'Dim m_boolQuesCallbackBusy As Integer

Sub Main()
'''ReadSiteInfo
End Sub
''Sub loadvatrates()
'''--------------------------VAT default file-----------------------------------
'''17 Jan 92 ASC
'''29Dec93 CKJ Added new VAT file
'''25Jan94 CKJ Added new items
'''16Feb95 CKJ Concatenated
''
''Dim fil%, lin%
''Dim strInput As String
''Dim pathfile As String
''
''   'If fileexists(dispdata$ & "\storevat.def") Then
''   '      fil = FreeFile
''   '      Open dispdata$ & "\storevat.def" For Input As #fil
''   '      Input #fil, TransLogVAT%, OrderLogVAT%, Highfact!, Lowfact!, entercostonreceipt$, tofollow%
''   '      For lin = 0 To 9
''   '         If EOF(fil) Then Exit For
''   '         Line Input #fil, strInput
''   '         VAT(lin) = Val(strInput)    ' 1 1.175 etc
''   '      Next
''   '      If Not EOF(fil) Then Input #fil, UtilOrdNum$, UtilSupplier$, UtilReasonNew$, UtilReasonMod$
''   '      Close #fil
''   '      TransLogVAT% = (TransLogVAT% <> 0) 'force boolean
''   '      OrderLogVAT% = (OrderLogVAT% <> 0)
''   '   End If
''
''   pathfile = dispdata$ & "\WorkingDefaults.ini"
''   OrderLogVAT% = Val(TxtD(pathfile, "", "", "OrderLogVAT", 0))
''   TransLogVAT% = Val(TxtD(pathfile, "", "", "TransLogVAT", 0))
''   Highfact! = Val(TxtD(pathfile, "", "", "Highfact", 0))
''   Lowfact! = Val(TxtD(pathfile, "", "", "Lowfact", 0))
''   entercostonreceipt$ = TxtD(pathfile, "", "", "entercostonreceipt", 0)
''   tofollow% = Val(TxtD(pathfile, "", "", "tofollow", 0))
''   For lin = 0 To 9
''      VAT(lin) = Val(TxtD(pathfile, "", "", "VAT(" & Format$(lin) & ")", 0))
''   Next
''   UtilOrdNum$ = TxtD(pathfile, "", "", "UtilOrdNum", 0)
''   UtilSupplier$ = TxtD(pathfile, "", "", "UtilSupplier", 0)
''   UtilReasonNew$ = TxtD(pathfile, "", "", "UtilReasonNew", 0)
''   UtilReasonMod$ = TxtD(pathfile, "", "", "UtilReasonMod", 0)
''   TransLogVAT% = (TransLogVAT% <> 0) 'force boolean
''   OrderLogVAT% = (OrderLogVAT% <> 0)
''
''End Sub




Sub ArrayToStruct()
'23Nov98 TH added extra drug elements(lastissued,lastordered,loccode2)
'25Nov98 TH added created & modified fields
'01Feb99 TH Ensure received price available for non stock items
'03Jun99 SF/CFY now updates "d.datelastperiodend" as ddmmyyyy
'13Aug01 SF added PIL2 field for CMI enhancement
'08Jan02 TH added StripSize for Pyxis enhancement (#56462)
'07Apr10 AJK New fields ported from v8 for F0072782 and F0072542
'14Apr10 AJK Added fields for F0072782
'13Jun13 TH  Added ExpiryWarnDays(TFS 39884)

Dim temp1$, temp2$, mult#, valid%

   d.Code = UCase$(presentent$(1))
   d.LabelDescription = presentent$(2)    ' d.Description = presentent$(2) XN 4Jun15 98073 New local stores description
   d.tradename = presentent$(3)
   d.cost = presentent$(4)
   d.contno = presentent$(5)
   d.supcode = presentent$(6)
   d.altsupcode = presentent$(7)
   d.ledcode = presentent$(8)
   d.SisCode = UCase$(presentent$(9))
   d.barcode = presentent$(10)
   d.cyto = UCase$(presentent$(11))
   d.civas = UCase$(presentent$(12))
   d.formulary = UCase$(presentent$(13))
   d.bnf = presentent$(14)
   Parsebnfcode d.bnf    '16Aug93 CKJ Added
   d.warcode = UCase$(presentent$(15))
   d.inscode = UCase$(presentent$(16))
   d.dircode = UCase$(presentent$(17))
   d.labelformat = UCase$(presentent$(18))
   temp1$ = Trim(UCase$(presentent$(19)))
   temp2$ = ""
   If Len(temp1$) Then temp2$ = Left$(temp1$, Len(temp1$) - 1)
   Select Case Right$(temp1$, 1)
      Case "H":  mult# = 60
      Case "D":  mult# = 1440
      Case "W":  mult# = 1440 * 7
      Case "Y":  mult# = 1440 * 365.25
      Case Else: mult# = 1: temp2$ = temp1$
      End Select
   d.expiryminutes = Val(temp2$) * mult#
   d.sisstock = UCase$(presentent$(20))
   d.LeadTime = presentent$(21)
   d.reorderpcksize = presentent$(22)
   d.PrintformV = LCase$(presentent$(23))
   d.minissue = presentent$(24)
   d.maxissue = presentent$(25)
   d.reorderlvl = presentent$(26)
   d.reorderqty = presentent$(27)
   d.convfact = presentent$(28)
   d.anuse = presentent$(29)
   d.message = presentent$(30)
   d.therapcode = UCase$(presentent$(31))
   d.extralabel = presentent$(32)
   d.stocklvl = presentent$(33)
   If Trim$(presentent$(34)) = "" Then presentent$(34) = presentent$(4)   '01Feb99 TH Ensure received price available for non stock items
   d.sislistprice = presentent$(34)
   d.contprice = presentent$(35)
   d.livestockctrl = UCase$(presentent$(36))
   d.loccode = LTrim$(presentent$(37))  'ltrim added 3Nov92
   'd.datelastperiodend = presentent$(38)
   parsedate presentent$(38), d.datelastperiodend, "3", valid '12Apr97 CKJ Any date -> ddmmyy   '03Jun99 SF/CFY action was "4"
   d.safetyfactor = Val(presentent$(39))
   d.usagedamping = Val(presentent$(40))
   d.usethisperiod = Val(presentent$(41))
   d.inuse = UCase$(presentent$(42))
   d.mlsperpack = Val(presentent$(43))
   d.recalcatperiodend = UCase$(presentent$(44))
   d.lossesgains = Val(presentent$(45))
   d.ordercycle = presentent$(46)
   d.cyclelength = Val(presentent$(47))
   d.outstanding = Val(presentent$(48))
   d.vatrate = UCase$(presentent$(49))         '23Dec93 CKJ mod
   d.DosingUnits = Trim(presentent$(50))       ' " new
   d.dosesperissueunit = Val(presentent$(51))  ' "
 '!!**  d.WorksheetNo = Val(presentent$(52))        ' "
   d.ATC = UCase$(presentent$(53))             ' "
   d.ATCCode = UCase$(presentent$(54))         ' "
   d.UserMsg = UCase$(presentent$(55))         '16Mar94 CKJ
   d.ReconVol = Val(presentent$(56))           '<- CIVA 29Mar94 ASC
   d.ReconAbbr = UCase$(presentent$(57))       'ASC 19Apr94
   d.mgPerml = Val(presentent$(58))
   d.MaxmgPerml = Val(presentent$(59))
   d.MinmgPerml = Val(presentent$(60))
   d.Diluent1Abbr = UCase$(presentent$(61))
   d.Diluent2Abbr = UCase$(presentent$(62))
   d.IVcontainer = UCase$(presentent$(63))
   d.DisplacementVolume = Val(presentent$(64))
   temp1$ = Trim(UCase$(presentent$(65)))
   temp2$ = ""
   If Len(temp1$) Then temp2$ = Left$(temp1$, Len(temp1$) - 1)
   Select Case Right$(temp1$, 1)
      Case "H":  mult# = 60
      Case "D":  mult# = 1440
      Case "W":  mult# = 1440 * 7
      Case Else: mult# = 1: temp2$ = temp1$
      End Select
   d.InfusionTime = Val(temp2$) * mult#             '   "
   d.MaxInfusionRate = Val(presentent$(66))         '<-to here 29Mar94 ASC
   d.PILnumber = Val(presentent$(67))               '13Jun94 CKJ added
   d.warcode2 = UCase$(presentent$(68))             '20Mar95 CKJ added
   d.deluserid = UCase$(presentent$(69))            ' 1Mar97 CKJ added
   d.indexed = UCase$(presentent$(70))              ' 8Mar97 CKJ added
   d.lastreconcileprice = presentent$(71)           '   "
   d.local = presentent$(72)                        '17Jul97 CKJ Added  *7
   d.MinDailyDose = Val(presentent$(73))            '   "               Single
   d.MaxDailyDose = Val(presentent$(74))            '   "               Single
   d.MinDoseFrequency = Val(presentent$(75))        '   "               Single
   d.MaxDoseFrequency = Val(presentent$(76))        '   "               Single
   ''d.route = presentent$(77)                        '   "               *20
   d.chemical = presentent$(78)                     '   "               *50
   ''d.DosesPerAdminUnit = Val(presentent$(79))       '22Sep97 SF added  Double
   ''d.adminunit = presentent$(80)                    '22Sep97 SF added  *5
   d.DPSform = presentent$(81)                      '12Dec97 CKJ adedd *25
   d.storesdescription = presentent$(82)            '29Dec97 EAC added *56
   d.storespack = presentent$(83)                   '29Dec97 EAC added *5
   d.teamworkbtn = Val(presentent$(84))             '29Dec97 EAC added integer
   'd.teamworkbtn = Val(presentent$(85))
   d.loccode2 = presentent$(86)                '23Nov98 Th added *3
   d.lastissued = presentent$(87)              '23Nov98 Th added *8
   d.lastordered = presentent$(88)             '23Nov98 Th added *8
   d.CreatedUser = presentent$(89)             '25Nov98 Th added *3
   d.createdterminal = presentent$(90)         '25Nov98 Th added *15
   d.createddate = presentent$(91)             '25Nov98 Th added *8
   d.createdtime = presentent$(92)             '25Nov98 Th added *6
   d.modifieduser = presentent$(93)            '25Nov98 Th added *3
   d.modifiedterminal = presentent$(94)        '25Nov98 Th added *15
   d.modifieddate = presentent$(95)            '25Nov98 Th added *8
   d.modifiedtime = presentent$(96)            '25Nov98 Th added *6
   d.batchtracking = presentent$(97)           '22Dec98 CFY Added
   d.pflag = presentent$(98)                   '01Feb99 TH Added *1
   d.issueWholePack = presentent$(99)          '23Feb99 SF added
   ''d.HasFormula = presentent$(100)             '11Oct99 CKJ added
   ' kinetics
   d.PIL2 = presentent$(116)                   '13Aug01 SF added for CMI enhancement
   d.StripSize = presentent$(117)              '08Jan02 TH added for Pyxis enhancement (#56462)

   d.pipcode = presentent$(118)                '28Mar02 ATW added PIP code for BMI/Wales requirements
   d.MasterPip = presentent$(119)
   d.LabelInIssueUnits = TrueFalse(presentent$(120))
   d.CanUseSpoon = TrueFalse(presentent$(121))
   d.PhysicalDescription = presentent$(122)  '16Jul09 TH Added
   '07Apr10 AJK Ported from v8 for F0072782 and F0072542
   d.DDDValue = presentent$(123)
   d.DDDUnits = presentent$(124)
   d.UserField1 = presentent$(125)
   d.UserField2 = presentent$(126)
   d.UserField3 = presentent$(127)
   d.HIProduct = presentent$(128)
   '14Apr10 AJK Added fields for F0072782
   d.EDILinkCode = presentent$(129)
   d.PASANPCCode = presentent$(130)
   d.PNExclude = TrueFalse(presentent$(131)) '27Jan12 CKJ
   d.EyeLabel = TrueFalse(presentent$(134))  '24Feb13 TH Changes prior to main merge for March
   d.PSOLabel = TrueFalse(presentent$(135))  '07Aug12 TH '24Feb13 TH changed array number
   d.ExpiryWarnDays = Val(presentent$(136))  '13Jun13 TH Added (TFS 39884)

End Sub
Public Sub Ques_Callback(Index As Integer)

'09Aug99 SF added Patient Billing maintenance
'17Sep99 AE Added calls for diagnosis / presenting complaints codes.
'10Feb00 TH Added call for SupProfiles
'16Nov00 SF added Prescriber callback
'11Apr02 ATW added case 18 callback

Const procname$ = "Ques_Callback"

Dim NewIndex%, msg$

   Select Case QuesCallbackMode
      Case 10: StkMaint_Callback Index                       'Stock (drug) maintenance
''      Case 11: Supplier_Callback Index                       'Amend Supplier Details
''      Case 12: PatientBilling_Callback Index                 '09Aug99 SF added Patient Billing maintenance
''      Case 13, 14, 15: Codes_CallBack Index                     '17Sep99 AE Added
      Case 16: SupProfile_CallBack Index        '10Feb00 TH *GST*
''      Case 17: Rx_Callback Index                             '16Nov00 SF added
''      Case 2, 3 'Set Working Defaults, Mediate EDI Link Settings
'''@~@~         Storeasc_Callback Index
''      'Case 2 'Set Working Defaults
''      '    CheckWorkingDefaults Index, msg$, NewIndex%
''      'Case 3 'Mediate EDI Link Settings
''      '    CheckMediateSettings Index, msg$, NewIndex%
''      Case 18: ExternalPricing_Callback Index    '11Apr02 ATW  Calls back to extention                                       ' external drug pricing
''
''      Case Else
''         popmessagecr "Error", "Module : " & modulename$ & cr & "Procedure : " & ProcName$ & cr & "Undefined callback number : " & Str$(QuesCallbackMode) & cr & cr & "Please report this error to ASC Computer Software Ltd."
      End Select

End Sub
Sub StkMaint_Callback(ByVal intIndex As Integer)
'27Jun97 CKJ Added VAT rate lookup
'25Jul97 CKJ Added Label Format
'12Aug97 CKJ Added call to QuesPrint
'16Mar99 TH  Code to unload dosaferevents if calling other modal form
'08Jul99 AE Added new lookup codes for Pharmacokinetics
'01Feb00 AE  Added code 115 for phamacokinetics
'21Mar00 AE  Removed case 100 as appears superfluous
'08oct08 CKJ DisplayBNFsectionlist replaces displaymacrofile

'!!** More needed
                                                                                          
Dim ptr%, extra$, Code$, desc$, badcheck%, cop$, param$, tmp$, valid%, FILE$, fil%
Dim CANCELLED As Integer
Dim success As Integer
Dim sAbbrev As String

   If intIndex = 1000 Then          'Print      12Aug97 CKJ Added
         QuesPrintView "", "Stock File :   +"
      ElseIf intIndex < 0 Then      'Shift-F1
         ptr = Val(Ques.lblDesc(-intIndex).Tag)
         Select Case ptr
            Case 6, 7, 14 To 18, 32, 49, 50, 67, 68, 102 To 104, 108 To 110, 115 'lookup codes '08Jul99 AE added 101-103,107-109   01Feb00 AE Added 115
               extra$ = ""                                                                 '15Oct99 AE Inc by 1
               Select Case ptr
                  Case 6, 7      'supplier code, alternative supplier codes
                     'Code$ = "PROFILES"  '09Oct06 TH Added
                     'ChooseSupplier Code$, desc$
                     'If ptr = 7 Then extra$ = Trim$(Ques.txtQ(-Index)) & " "
                     '12Oct06 TH On reflection this should just be removed, otherwise it could save incorrect profile fields
                     If Trim$(d.supcode) <> "" Then
                        popmessagecr "", "Use Set Primary Supplier to change this field"
                     Else
                        ChooseSupplier Code$, desc$
                        If ptr = 7 Then extra$ = Trim$(Ques.txtQ(-intIndex)) & " "
                     End If
                  Case 14        'BNF code
                     'displaymacrofile dispdata$ & "\BNFsect.dat", "BNF Chapter.Section", Code$, desc$, True
                     'displaymacrofile "\BNFsect", "BNF Chapter.Section", Code$, desc$, True
                     Code$ = Ques.txtQ(-intIndex)                                         '08oct08 CKJ replaces displaymacrofile
                     DisplayBNFsectionlist 0, "BNF Chapter and Section", Code$, desc$     '   "
                  Case 15, 68    'Warning, 2y warning
                     'displaymacrofile dispdata$ & "\Warning.v4", "Warning Code", code$, desc$           '14Jul98 CKJ
                     ''displaymacrofile (ASCFileName("warning.v4", 1, "")), "Warning Code", Code$, desc$, True  '14Jul98 CKJ
                     'displaymacrofile "warning", "Warning Code", Code$, desc$, True  '14Jul98 CKJ
                     ListWarnings Code$, desc$, CANCELLED
                  Case 16        'Instruction
                     'displaymacrofile dispdata$ & "\instruct.v4", "Instruction Code", code$, desc$         '14Jul98 CKJ
                     ''displaymacrofile (ASCFileName("instruct.v4", 1, "")), "Instruction Code", Code$, desc$, True '14Jul98 CKJ
                     ListInstructions Code$, desc$, CANCELLED
                  Case 17        'Direction
''                     ChooseDirection code$, desc$
''                     extra$ = Trim$(Ques.txtQ(-Index))
''                     If Len(extra$) Then extra$ = extra$ & "/"
                  Case 18        'Label Format
''                     ChooseLabelFormat code$, desc$
                  Case 32        'Extra Label
                     'displaymacrofile dispdata$ & "\fflabels.dat", "Extra Label", Code$, desc$, True
                     displaymacrofile "fflabels", "Extra Label", Code$, desc$, True
                  Case 49        'VAT rate
                     ChooseVATcode Code$, desc$
                  Case 50        'Dosing units
                     ChooseDosingUnits Code$, desc$
                  Case 67        'PIL
                     ChoosePIL Code$, desc$
''                  Case 102, 104, 108 To 110, 115                          '08Jul99 AE added. 01Feb00 AE Added 115
''                     KineticsAssist ptr, -Index, dKin, Stkmaint$
                  
                  End Select
               If Not CANCELLED Then
                  If Len(Code$) Then
                     Ques.txtQ(-intIndex) = LTrim$(extra$ & Code$)
                     Ques.lblInfo(-intIndex) = desc$
                  Else
                     Ques.lblInfo(-intIndex) = "Shift-F1 for list"
                  End If
               End If
            End Select

      Else
         ptr = Val(Ques.lblDesc(intIndex).Tag)
         Select Case ptr
            Case 1               'ASC code modified
               badcheck = 3      '!!** or maybe 2
               cop$ = d.Code
               'd.code = RTrim$(presentent$(Ptr))
               d.Code = RTrim$(Ques.txtQ(intIndex))
               checkcode badcheck
               d.Code = cop$
               
            Case 6 '09Oct06 TH Added - Ensure Supplier is valid (has associated supplier profile record
''               If Trim$(Ques.txtQ(Index)) <> "" Then
''                  param$ = "," & Trim$(Ques.txtQ(Index)) & ","
''                  If InStr("," & GetProductSupplierString(d.SisCode) & ",", param$) = 0 Then
''                     On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
''                     Unload frmDoEvents        '   "
''                     If Err Then               '   "
''                        Err = 0                '   "
''                     End If                    '   "
''                     popmessagecr "WARNING", "Supplier code " & param$ & " is not a valid supplier for this Product." & crlf & "Please enter a valid supplier or add a supplier profile record for this supplier."
''                     Ques.txtQ(Index) = ""
''                  End If
''               Else
''                  Ques.lblInfo(Index) = "Shift-F1 for list"
''               End If
               '12Oct06 TH On reflection this should just be removed, otherwise it could save incorrect profile fields
               If Trim$(d.supcode) <> "" Then
                  On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
                  Unload frmDoEvents        '   "
                  If Err Then               '   "
                     Err = 0                '   "
                  End If
                  popmessagecr "", "Use Set Primary Supplier to change Supplier Code"
                  Ques.txtQ(intIndex) = d.supcode
''               Else
''                  If Trim$(Ques.txtQ(intIndex)) <> "" Then
''                     param$ = "," & Trim$(Ques.txtQ(intIndex)) & ","
''                     If InStr("," & GetProductSupplierString(d.SisCode) & ",", param$) = 0 Then
''                        On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
''                        Unload frmDoEvents        '   "
''                        If Err Then               '   "
''                           Err = 0                '   "
''                        End If                    '   "
''                        popmessagecr "WARNING", "Supplier code " & param$ & " is not a valid supplier for this Product." & crlf & "Please enter a valid supplier or add a supplier profile record for this supplier."
''                        Ques.txtQ(intIndex) = ""
''                     End If
''                  Else
''                     Ques.lblInfo(intIndex) = "Shift-F1 for list"
''                  End If
               End If
            Case 35  '31Jan96 EAC - check for contract price varying by greater than xx% - xx being read from .ini file
               param$ = Trim$(Ques.txtQ(intIndex))
               If param$ <> Trim$(d.contprice) And Trim$(d.SisCode) <> "" And Val(param$) <> 0 Then
                     If (Abs(Val(d.contprice) - Val(param$))) / Val(param$) > contpriceperc! Then
                           On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
                           Unload frmDoEvents        '   "
                           If Err Then               '   "
                              Err = 0                '   "
                           End If                    '   "
                           popmessagecr "WARNING", "Contract price has changed by more than " & Format$(contpriceperc! * 100) & "%"
                        End If
                  End If
            
            Case 38
               parsedate Ques.txtQ(intIndex), tmp$, "1-", valid '12Apr97 CKJ Any date -> dd-mm-ccyy
               Ques.txtQ(intIndex) = tmp$

            Case 67
               Select Case 1! * Val(Ques.txtQ(intIndex))
                  Case Is < 0
                     On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
                     Unload frmDoEvents        '   "
                     If Err Then               '   "
                        Err = 0                '   "
                     End If                    '   "
                     popmessagecr "EMIS Health", "Warning - negative values are not permitted"
                     Ques.txtQ(intIndex) = ""
                  Case Is > 32767
                     On Error Resume Next      '16Mar99 TH  Was calling msgbox while do events still modally shown
                     Unload frmDoEvents        '   "
                     If Err Then               '   "
                        Err = 0                '   "
                     End If                    '   "
                     popmessagecr "EMIS Health", "Warning - maximum value of 32767 exceeded"
                     Ques.txtQ(intIndex) = ""
                  End Select

'            Case 100         'Print view             21Mar00 AE  Removed block as appears superfluous
'               MakeLocalFile file$
'               fil = FreeFile
'               Open file$ For Output As #fil
'               Print #fil, HospName1$; " "; Hospname2$
'               Print #fil, "Printed by "; UserID$; " "; UserFullName$; "    Date: "; Mid$(Date$, 4, 3); Left$(Date$, 3); Mid$(Date$, 7); "    Time: "; Left$(Time$, 5)
'               Print #fil,
'               Print #fil, Space$(20); 'stock item description & ref number
'               Print #fil,
'               Print #fil,
'              ' For Count = 1 To items
'              '    code$ = Space$(codemax)
'              '    LSet code$ = codes(Count)
'              '    Print #fil, "   "; code$; " .... "; exps(Count)
'              ' Next
'               Print #fil,
'               Print #fil, Space$(10); "---------- End of list ----------"
'               Close #fil
'               spool file$
            Case 103          '??jul99 AE Added.  Change pharmacokinetic Model    '15Oct99 AE Inc by 1
''               KineticsAssist ptr, Index, dKin, Stkmaint$
            Case 132 '12Jul12 CKJ Added. Swap primary & secondary stock locations
               Code = Ques.txtQ(1)
               Ques.txtQ(1) = Ques.txtQ(2)
               Ques.txtQ(2) = Code
               
            Case 133 'Edit abbreviation rules
               '17Jul12 CKJ Written. Rowa needs description checking & pruning
               'GetTextFile dispdata$ & "\abbrevrule.txt", sAbbrev, success
               sAbbrev = TxtD(dispdata$ & "\mechdisp.ini", "common", "", "AbbreviationRules", 0) '1024 max - not long enough
                           
               Editor.lblTitle.Caption = "Edit the abbreviation rules for shortening product descriptions"
               Editor.cmdBtn(1).Visible = False
               Editor.cmdBtn(0).Visible = False
               Editor.cmdExit.Caption = "&OK"
               Editor.Txt1.Text = sAbbrev
               Editor.Txt1.Tag = sAbbrev
               Editor.lblCode.Caption = ""   'box in lower left corner
               'Editor.lblTitle.Caption = title$
               Editor.Caption = "Abbreviation Rules"
               Editor.cmdExit.default = False    'view & edit
               Editor.Tag = ""           'allow full size editing
               gTimedOut = False
               Editor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
               sAbbrev = Editor.Txt1.Text
               'change = Val(Editor.cmdExit.Tag)
               k.escd = (Editor.cmdExit.Tag <> "-1")
               Unload Editor
                        
               If Not k.escd Then
                  WritePrivateIniFile "common", "AbbreviationRules", sAbbrev, dispdata$ & "\mechdisp.ini", success
               End If
            End Select
      End If

End Sub

Sub checkcode(badcheck%)
'-------------------------------------------------------------------------------
'Checks the dispensary drug code is AAAA111 or a truncation
'If badcheck = 2 then check is on code alone
'
'22Nov90 CKJ badcheck of 3 suppresses the popup window
'26Oct94 CKJ Checking with drug name now removed. Badcheck of 2 ignored
'            Popwin reduced
'            Use of '-' in a code is no longer valid
'28Jan99 CFY Changed wording of message if an invalid code is found.
'08Feb99 CFY Removed hard coded pattern mask. Now uses masks from stkmaint.ini
'06Apr99 TH  Removed code to match 8066
'
'-------------------------------------------------------------------------------

Dim lookup$
Dim match%
   
Dim Popwin%, temp$               '28Jul99 AE Dim'd variable
   If badcheck = 3 Then Popwin = False Else Popwin = True
   badcheck = False
   'If badcheck <> 2 And UCase$(Left$(d.code, 2)) <> UCase$(Left$(d.description, 2)) Then  '06Apr99 TH Taken out to match 8066
   '     badcheck = True                                                                   '  "
   '  End If                                                                               '  "
   'temp$ = RTrim$(UCase$(dcop.Code))
   temp$ = RTrim$(UCase$(d.Code)) 'SQL

   If Len(temp$) < 3 Then badcheck = True
   
                                                                                            '         "
   
   If Not badcheck Then                                                                                     '08Feb99 CFY Added
         match% = False
         lookup$ = LookupPattern()                                                                          '         "
         If lookup$ <> "" Then
               If Len(lookup$) > Len(temp$) Then                                                                  '         "
                     lookup$ = Left$(lookup$, Len(temp$))                                                         '         "
                  End If                                                                                          '         "
               match% = PatternMatch(temp$, lookup$)                                                              '         "
            End If
         badcheck = Not match%                                                                              '         "
      End If                                                                                                '         "
                                                                                                            '         "
   If badcheck And Popwin Then
         'popmessagecr "!n!bIncorrect Drug Code", "ASC code should be up to four letters & numbers"         '28Jan99 CFY
         'popmessagecr "!n!bIncorrect Drug Code", "Look up code is invalid"                                 '       "      '26Apr99 CFY
''         popmessagecr "!n!bIncorrect Drug Code", "Look up code is missing or invalid"                                      '              "
         'pickwindow 10, 53, "!n!bINCORRECT DRUG CODE", 4
         'printwcr ""
         'printwcr "  The first two letters of the drug code must be"
         'printwcr "  the first two letters of the drug name."
         'printwcr ""
         'printwcr "  It is suggested that this is followed by one"
         'printwcr "  letter for form, eg T for tablets, then"
         'printwcr "  three digits for the strength, volume or size."
         'printwcr "  The last digit is used to differentiate between"
         'printw "  drugs which would otherwise have identical codes."
         'k.ret = true
         'k.helpnum = 110
         'LOCATE , , 0
         'inputchar dd$, k
         'closewindow
         'LOCATE , , 1
      End If
End Sub

Public Sub ViewSelected(ViewNumber, Viewname$)

'20Mar09 TH  Added mods for UHB stock interface (F0032689)
'10Jun10 XN Got it to use DSSUpdateServiceInUse instead of the DSSMaster flag, and ProductID <> 0 instead of InUse<>"S" (F0088717)
'02Nov10 AJK F0086901 Added paydate to OrderLog calls
'09Oct13 XN  Config setting to allow certain sites to edit a drug if they are on DSSOnWeb (TFS 75466)
'15Nov13 XN  Moved labutils.log to WPharmacyLog table 56701

Static LastView As Integer
Const Stkmaint$ = "\stkmaint.ini"

Dim NumOfEntries As Integer
Dim intloop As Integer
Dim tmp$
Dim ptr As Integer
Dim Info$, Summary$
Dim SomeChange As Boolean
Dim dcop As DrugParameters
Dim dwas$
Dim TotFields As Integer
Dim FullAccess%
Dim dcopy As DrugParameters
Dim passed As Integer
Dim txt$
Dim dnow$
Dim ans$, adjust$
Dim typemsg$, dat$
'Dim logging As Integer
Dim OldStockValue!, NewStockValue!
Dim adjnum As Long
Dim blnOK As Boolean
Dim dSiteProdEdit As DrugParameters
Dim siteProductData() As Boolean
Dim lngProductID As Long
Dim strParams As String
'Dim lngProductStockID As Long
Dim blnUnlocked As Boolean
Dim lngResult As Long
Dim blnDuplicate As Boolean
Dim blnLock As Boolean
Dim strDesc As String
Dim StoresOnlyProductID As Long  '13Feb06 TH Added
Dim DSSMasterSiteID As Long  '04May06 TH Added
Dim strForceState As String '22oct08 AK Added (F0018781)
Dim blnCreate As Boolean '20Mar09 TH Added (UHB)
Dim dummy As Integer

FullAccess = True

   blnCreate = False '20Mar09 TH Added (UHB)
   TotFields = Val(TxtD(dispdata$ & Stkmaint$, "data", "0", "Total", 0))
   If TotFields = 0 Then
      ''popmessagecr "Error", "Cannot find Stock Maintenance configuration file; " & Stkmaint$
      popmessagecr "Error", "Cannot find Stock Maintenance configuration Settings"
      Exit Sub
   End If
   
   ReDim presentent$(TotFields)
   
   dcop = d
   LSet r = d
   dwas$ = Left$(r.record, Len(d))
   StructToArray
   Summary$ = ""
   'getdrug d, d.ProductStockID, 0, True 'found, True    '<== LOCK '' 01Jun02 ALL/ATW found not used in this Gosub
   dcopy = d
   Select Case ViewNumber
      Case Is >= 1
         Do
            'x'ReDim siteProductData(TotFields) '30Jun05 TH
            ''If Not k.escd Then                                      '??jul99 AE added if...
            ''setmodulardrug d
            ''lngProductID = d.ProductID
            '''strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
            '''           gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
            '''lngProductStockID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetProductStockIDfromProductIDandSiteID", strParams)
            '29Aug05 Added fencepost
            If d.productstockID > 0 Then
               getdrug d, d.productstockID, 0, True 'found, True    '<== LOCK '' 01Jun02 ALL/ATW found not used in this Gosub
               blnLock = True
            End If
            blnUnlocked = False
            d.ProductID = gProductID '05Jul05 TH Needed incase this is a new item (with no stockline yet)
            '''d.ProductStockID = lngProductStockID 'TH Why is this needed ???
            LastView = ViewNumber
            
            '22oct08 AK If DSS maintained product and DSS Master switch is true then get read only field array from setting to pass to ConstructView (F0018781)
            '10Jun10 XN Got below to use the DSSUpdateServiceInUse instead of the DSSMaster flag, and ProductID <> 0 instead of InUse<>"S" (F0088717)
            'If d.DrugID < 10000000 And UCase(SettingValueGet("Security", "Settings", "DSS Master")) = "TRUE" Then
            '09Oct13 XN  Config setting to allow certain sites to edit a drug if they are on DSSOnWeb (TFS 75466)
            'If d.DrugID < 10000000 And UCase(SettingValueGet("System", "Reference", "DSSUpdateServiceInUse")) = "TRUE" And d.ProductID <> 0 Then
            If d.DrugID < 10000000 And _
                    UCase(SettingValueGet("System", "Reference", "DSSUpdateServiceInUse")) = "TRUE" And _
                    d.ProductID <> 0 And _
                    TrueFalse(TxtD(dispdata$ & "\stkmaint.ini", "DSSLockDown", "N", "AllowEditProduct", 0)) = False Then
               strForceState = "," & SettingValueGet("Security", "Settings", "DSS Maintained Fields")
               replace strForceState, ",", "¬", 0
               replace strForceState, "¬", ",-", 0
               strForceState = Mid$(strForceState, 2)
            Else
               strForceState = "" '22oct08 AK No read only fields (F0018781)
            End If
            
            ConstructView dispdata$ & Stkmaint$, "Views", "Data", ViewNumber, strForceState, 0, Viewname$, NumOfEntries
            Ques.Caption = Viewname$ & " - Number" & Str$(ViewNumber)
            TimeoutOff Ques.Timer1   '20Mar07 TH
            Ques.Tag = "timeoutoff"  '   "
            For intloop = 1 To NumOfEntries
               QuesSetText intloop, RTrim$(presentent$(Val(Ques.lblDesc(intloop).Tag)))
            Next
            QuesMakeCtrl 0, 1000                 '12Aug97 CKJ Show print button
      
            QuesCallbackMode = 10
            QuesShow NumOfEntries                '<== Edit now
            QuesCallbackMode = 0
            
            dSiteProdEdit = d
            
            For intloop = 1 To NumOfEntries
               tmp$ = QuesGetText(intloop)
               ptr = Val(Ques.lblDesc(intloop).Tag)
               If tmp$ <> RTrim$(presentent$(ptr)) Then
                  '17Jul97 CKJ Add cr if line is long
                  Info$ = pad$((Ques.lblDesc(intloop)), 25) & " " & "Was : '" & RTrim$(presentent$(ptr)) & "'"
                  If Len(RTrim$(presentent$(ptr))) + Len(tmp$) > 50 Then Info$ = Info$ & cr & Space$(25)
                  Info$ = Info$ & " Now : '" & tmp$ & "'"
                  Summary$ = Summary$ & Info$ & cr
                  SomeChange = True
                  'log changes here
                  'x'siteProductData(ptr) = True
                  'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & " " & Info$
                  WriteLogSQL Info$, "labutils", 0, 0, d.SisCode    ' XN 15Nov13 Moved labutils.log to WPharmacyLog 56701
               End If
               presentent$(ptr) = tmp$
            Next
            'If Len(Summary$) Then popmessagecr "", Summary$    'for debugging
            '''Unload Ques
            '''If FixedView Then ViewNumber = 0     'exit
                        
           
            ''End If                                                  '??Jul99AE Added
            If Trim$(Ques.Tag) = "" Then     '29Jun05
               ViewNumber = 0                '29Jun05
               k.escd = True  '26Oct05 TH Added
               Unload Ques
               Screen.MousePointer = STDCURSOR  '29Jun05
               '11Jul05 TH Added block
               d = dcopy
               'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode + " ESCAPED " + typemsg$
               WriteLogSQL " ESCAPED " + typemsg$, "labutils", 0, 0, d.SisCode    ' XN 15Nov13 Moved labutils.log to WPharmacyLog 56701
               'If d.ProductStockID <> 0 Then putdrug d
               If blnLock Then
                  putdrug d
                  blnLock = False
               End If
               '-----------
            Else                                '29Jun05
               Unload Ques
               If FullAccess% Then                                   '16Feb99 CFY Added
                  'Checkdrug d.productstockID, passed, txt$                       'check validity here
                  Checkdrug d.productstockID, passed, txt$
               Else                                               '16Feb99 CFY Added
                  passed% = True                                  '        "
               End If                                             '        "
               If Not FullAccess Then
                  If Not passed Then popmessagecr "Please note:", txt$
               ElseIf passed Then
                  ArrayToStruct
                  LSet r = d
                  dnow$ = Left$(r.record, Len(d))
                  If SomeChange Or dnow$ <> dwas$ Then 'Manual or automatic change made
                     ans$ = "Y"
                     askwin "?Item modified", Summary$ & cr & "OK to save the changes?", ans$, k
                     If ans$ = "Y" Then             'yes, save changes and exit
                        SomeChange = True
                        ViewNumber = 0 '22Jun05 TH Added
                     ElseIf ans$ = "N" Then
                        SomeChange = False       'no, discard changes and exit
                        d = dcop
                        ViewNumber = 0 '22Jun05 TH Added
                     Else                        'esc chosen, stay in the loop
                        ViewNumber = LastView
                        k.escd = False '22Jun05 TH Added
                        SomeChange = False '03Sep07 TH Added. Without this cancelled changes still get saved !!!
                     End If
                  Else
                     ViewNumber = 0 '22Jan07 TH Added
                  End If
               Else
                  'ans$ = "Y"
                  ans$ = "N"  '12Oct05 TH Changed (#83590)
                  askwin "Exit Product Editor", txt$ & cr & "OK to exit without saving changes?", ans$, k
                  If ans$ = "Y" Then
                     SomeChange = False             'no, discard changes and exit
                     d = dcop
                     ''ClearDkinStruct          '09Jul99 AE Added for Pharmacokinetics
                     ''StructtoArrayKinetics    '       "
                     ViewNumber = 0
                  Else
                     ViewNumber = LastView
                     ''k.escd = True
                  End If
               End If
               If Not SomeChange Then
                  d = dcopy
                  'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode + " ESCAPED " + typemsg$
                  WriteLogSQL " ESCAPED " + typemsg$, "labutils", 0, 0, d.SisCode    ' XN 15Nov13 Moved labutils.log to WPharmacyLog 56701
                  If d.productstockID <> 0 Then putdrug d  '', -F&          '<== UNLOCK WITHOUT WRITING (05Jul05 TH but only if this is not a new product)
                  ''RegEdited = False                        '??Jul99 AE Added for Pharmacokinetics
                  If k.escd Then ViewNumber = 0 '22Jun05 TH Added
                  ''ViewNumber = 0 '22Jun05 TH  '11Jul05 TH put back
               Else                      '21Dec93 CKJ Rewritten
''                  dat$ = Mid$(date$, 4, 2) + Left$(date$, 2) + Right$(date$, 2)
''                  If logging And Val(d.stocklvl) <> Val(dcopy.stocklvl) Then    'stock level adj
''                     adjust$ = LTrim$(Str$(Val(d.stocklvl) - Val(dcopy.stocklvl)))
''                     Orderlog UtilOrdNum$, d.SisCode, UserID$, dat$, "", adjust$, "", dcopy.cost, UtilSupplier$, "S", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate  '20Dec93 CKJ Added pseudo codes
''                  End If
''
''                  OldStockValue! = Val(dcopy.stocklvl) * Val(dcopy.cost) + dcopy.lossesgains
''                  NewStockValue! = Val(d.stocklvl) * Val(d.cost) + d.lossesgains
''                  If logging And OldStockValue! <> NewStockValue! Then          'stock value adj
''                     ' NB No ModifyPrice used - store raw figures as entered
''                     adjust$ = LTrim$(Str$(NewStockValue! - OldStockValue!))
''                     getorderno -1, adjnum, True
''                     ' NB used to store NEW price
''                     Orderlog LTrim$(Str$(adjnum)), d.SisCode, UserID$, dat$, "", "0", "", adjust$, UtilSupplier$, "A", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate  '21Dec93 CKJ Rewritten transaction to mirror Finanasc
''                  End If
''
''                  WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode + " SAVED " + typemsg$
''                  d.modifieduser = Trim$(UserID$)
''                  d.modifiedterminal = ASCTerminalName()
''                  d.modifieddate = Format$(Now, "ddmmyyyy")
''                  d.modifiedtime = Format$(Time, "hhmmss")
                                             
         
                  'If dcopy.vatrate <> d.vatrate And (InStr(TxtD(dispdata$ & "\supprof.ini", "Views", "", "1", 0), "15") = 0) Then '25Aug00 TH
                  '   updatesupprofvatrate dcopy, d                                                                           '  "
                  'End If                                                                                                       '  "
                  'TH SQL we are inside a transaction here currently
                  'If d.ProductStockID = 0 Then
                  '   putdrug d
                  'Else
                  
                  'SQL - Here we need to ensure there is no duplication with the new constraints
                  'First we will check the SiteProductData Table
                  'The constraint here is based on the combo of ProductID ,DosesPerIssueUnit and convfact (for TM)
                  'Just ProductID for AMPP
                  '
''                  strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID)
''
''                  If blnAMPP Then
''                     strParams = strParams & gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, Null) & _
''                                             gTransport.CreateInputParameterXML("convfact", trnDataTypeFloat, 8, Null)
''                  Else
''                  'This is a TM level mapping
''                     strParams = strParams & gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) & _
''                                             gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact)
''                  End If
''                  lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDatabyCriteria", strParams)
''
''                  If lngResult > 0 Then blnDuplicate = True
'21Nov06 TH From here ''' Removed swathes of TM level matching code. YESSSS!!!!!!!!
'''                  If (Not blnAMPP) And (Not blnStoresOnly) And passed Then
                     
                  'This is a TM level mapping
                     '04May06 TH changed fencepost - was a nice idea for editing but not for creating new items from a template. Now do checks if new or if edit but key fields have changed
'''                     If (((d.convfact <> dcopy.convfact) Or (d.dosesperissueunit <> dcopy.dosesperissueunit) And d.productstockID <> 0) Or d.productstockID = 0) Then 'Add check to ensure duplication check only done when required
'''
'''                        strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
'''                        DSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParams)
'''
'''
'''                        strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID)
'''                        strParams = strParams & gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) & _
'''                                                gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact) & _
'''                                                gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, DSSMasterSiteID)
'''                     ''End If
'''                        lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDataForTMDuplicateCheck", strParams)
'''
'''                        If lngResult > 0 Then blnDuplicate = True
'''
'''                     'Now check product stock.
'''                     'Same constraints except here we are allowed duplicates if SiteID is different
'''   ''                  strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID) & _
'''   ''                              gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
'''
'''   ''                  If blnAMPP Then
'''   ''                     strParams = strParams & gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, Null) & _
'''   ''                                             gTransport.CreateInputParameterXML("convfact", trnDataTypeFloat, 8, Null)
'''   ''                  Else
'''   ''                  'This is a TM level mapping
'''   ''                     strParams = strParams & gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) & _
'''   ''                                             gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact)
'''   ''                  End If
'''   ''                  lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pProductStockbyCriteria", strParams)
'''   ''                  If lngResult > 0 Then blnDuplicate = True
'''                     ''If Not blnAMPP Then
'''
'''                        'This is a TM level mapping
'''                        strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, gProductID) & _
'''                                    gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'''                                    gTransport.CreateInputParameterXML("DosesPerIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) & _
'''                                    gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact)
'''
'''                        lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pProductStockCountbyCriteria", strParams)
'''                        If lngResult > 0 Then blnDuplicate = True
'''                     End If
'''                  End If
                  'If there is any problem then we warn the user here and set passed as false
'''                  If blnDuplicate Then
'''                     popmessagecr "!Product Stock Editor", "Cannot save this product as there is a conflict with an existing Stock line " & crlf & crlf & _
'''                     "A product at this level with the same Pack Size and Strength already exists !"
'''                     passed = False
'''                  End If
                  If passed Then
                     'Another check on siscode if we are adding a SiteProductData row
                     If d.SiteProductDataID = 0 Then
                        'Insert
                        strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                                    gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, d.SisCode)
   
                        lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDatabySiscodeandSiteID", strParams)
                        If lngResult > 0 Then blnDuplicate = True
                     End If
                     If blnDuplicate Then
                        popmessagecr "!Product Stock Editor", "Cannot save this product as there is a conflict with an existing Stock line " & crlf & crlf & _
                        "A product with this NSV Code already exists !"
                        passed = False
                        ViewNumber = LastView '21Feb07 TH Added to keep in the loop - lets at least give them an opportunity to change it
                        blnDuplicate = False  '   "
                     End If
                  End If
                  
                  '21Feb07 TH A Further check to warn if someone is trying to alter an NSVCode that is also used on another stockholding
                  If passed Then
                     If Trim$(UCase$(dcopy.SisCode)) <> Trim$(UCase$(d.SisCode)) Then
                        'Now we need to test to see if this is on another stockholding
                        strParams = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, d.DSSMasterSiteID) & _
                                    gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, d.SisCode)
   
                        lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductCountbySiscodeandDSSMasterSiteID", strParams)
                        If lngResult > 1 Then
                        'OK, now we need to warn in no uncertain fashion because this could be very bad indeed
                           ans$ = "N"
                           txt$ = "WARNING. This product Exists in other stockholdings." & "Altering the NSV Code can have serious implications. " & _
                           "Only continue if you are certain of the consequences." & _
                           "Your actions will be logged."
                           askwin "Product Editor Warning", txt$, ans$, k
                           If UCase$(ans$) <> "Y" Then
                              passed = False
                              ViewNumber = LastView
                           End If
                        End If
                     End If
                  End If
                  
                  If passed Then
                     '01Sep05 TH Moved block from above so as to log stuff only if we are definitely saving ????
                     dat$ = Mid$(date$, 4, 2) + Left$(date$, 2) + Right$(date$, 4) & Format$(Now, "HH") & Format$(Now, "NN") & Format$(Now, "SS")
                     'If logging And Val(d.stocklvl) <> Val(dcopy.stocklvl) Then    'stock level adj
                     If Val(d.stocklvl) <> Val(dcopy.stocklvl) Then    'stock level adj
                        adjust$ = LTrim$(Str$(Val(d.stocklvl) - Val(dcopy.stocklvl)))
                        'Orderlog UtilOrdNum$, d.SisCode, UserID$, dat$, "", adjust$, "", dcopy.cost, UtilSupplier$, "S", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "" '21Nov06 TH Added new params
                        'Orderlog UtilOrdNum$, d.SisCode, UserID$, dat$, "", adjust$, "", dcopy.cost, UtilSupplier$, "S", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog UtilOrdNum$, d.SisCode, UserID$, dat$, "", adjust$, "", dcopy.cost, UtilSupplier$, "S", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "", "", 0  '04Apr14 TH Added PSO param
                     End If
         
                     OldStockValue! = Val(dcopy.stocklvl) * Val(dcopy.cost) + dcopy.lossesgains
                     NewStockValue! = Val(d.stocklvl) * Val(d.cost) + d.lossesgains
                     'If logging And OldStockValue! <> NewStockValue! Then          'stock value adj
                     If OldStockValue! <> NewStockValue! Then          'stock value adj
                        ' NB No ModifyPrice used - store raw figures as entered
                        adjust$ = LTrim$(Str$(NewStockValue! - OldStockValue!))
                        getorderno -1, adjnum, True
                        ' NB used to store NEW price
                        'Orderlog LTrim$(Str$(adjnum)), d.SisCode, UserID$, dat$, "", "0", "", adjust$, UtilSupplier$, "A", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "" '21Nov06 TH Added new params
                        'Orderlog LTrim$(Str$(adjnum)), d.SisCode, UserID$, dat$, "", "0", "", adjust$, UtilSupplier$, "A", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "", "" '02Nov10 AJK F0086901 Added paydate
                        Orderlog LTrim$(Str$(adjnum)), d.SisCode, UserID$, dat$, "", "0", "", adjust$, UtilSupplier$, "A", SiteNumber, UtilReasonMod$ + " " + UtilOrdNum$, d.vatrate, "", "", "", "", 0   '04Apr14 TH Added PSO param
                     End If
         
                     'WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode + " SAVED " + typemsg$
                     WriteLogSQL " SAVED " + typemsg$, "labutils", 0, 0, d.SisCode    ' XN 15Nov13 Moved labutils.log to WPharmacyLog 56701
                     d.modifieduser = Trim$(UserID$)
                     d.modifiedterminal = ASCTerminalName()
                     d.modifieddate = Format$(Now, "ddmmyyyy")
                     d.modifiedtime = Format$(Time, "hhmmss")
                     '-------------------------------
                     '26Jan06 TH Removed as we no longer create new NMPs (We must match to a Pre-existing NMPP)
''                     If blnNMP Then
''                        'Create a new NMP here post the ID
''                        strDesc = d.storesdescription
''                        plingparse strDesc, "!"
''                        strParams = gTransport.CreateInputParameterXML("LookUpType", trnDataTypeVarChar, 50, "Default") & _
''                                    gTransport.CreateInputParameterXML("IndexGroup", trnDataTypeVarChar, 50, "Default") & _
''                                    gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 255, strDesc)
''                        gProductID = gTransport.ExecuteInsertSP(g_SessionID, "NMP", strParams)
                     '13Feb06 TH Added Block
                     If blnStoresOnly And d.ProductID = 0 Then
                        'Here we will generate a dummy productID in order to populate the mapper tables
                        ''GetPointerSQL dispdata$ & "\StoresProductID", StoresOnlyProductID, True
                        'GetPointerSQL rootpath$ & "\StoresProductID", StoresOnlyProductID, True
                        'gProductID = (StoresOnlyProductID) * -1
                        gProductID = 0
''                        If gProductID = 0 Then
''                           'Close up - configuration not setup correctly
''                        End If
                        
                     End If
                     If d.SiteProductDataID = 0 Then blnCreate = True '20Mar09 TH Added for UHB interface
                     d.ProductID = gProductID  '25Aug05 TH Added
                     blnOK = PutSiteProductDataNL(d, siteProductData())
                     d.ProductID = gProductID
                     '''d.ProductStockID = lngProductStockID
                     putdrug d '', F&          '<== WRITE & UNLOCK  logged   ' 01Jun02 ALL/ATW
                     blnLock = False
                     blnUnlocked = True
                     '20Mar09 TH UHB Interface here
                     If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "GenericInterface", "N", "StockInterface", 0)) Then StockOutput d, blnCreate  '20Mar09 TH Added (F0032689)
                  Else
                     d = dcopy
                     'If d.ProductStockID <> 0 Then putdrug d
                     If blnLock Then
                        putdrug d
                        blnLock = False
                     End If
                  End If
               End If
            End If '29Jun05
         Loop Until ViewNumber = 0
      Case -1: SuppBarcodes d.SiteProductDataID '.productstockID '01Apr07 TH Now use siteproductdata
      'Case -2: UserLogViewer "Dfs", "T", "", (d.SisCode), Format$(sitenumber) '15Oct97 CKJ Added
      'Case -3: UserLogViewer "Dfs", "O", "", (d.SisCode), Format$(sitenumber) '   "
      Case -2: UserLogViewer "Dfs", "T", "", (d.SisCode), Format$(SiteNumber), 3  '29May01 TH Added new search parameter
      Case -3: UserLogViewer "Dfs", "O", "", (d.SisCode), Format$(SiteNumber), 3  '   "
      ''Case -4: RestrictItem 2, d.SisCode      '15Jul98 CKJ set restriction by drug
      ''Case -5: RestrictItem 3, d.SisCode      '   "        set restriction by drug by site
      ''Case -6: EditExtraBilling d         '05Apr02 ATW   Added for BMI/Private billing from external catalog
      Case -4: EditSupProfile 0, 0
      Case -5: SetPrimarySupplier
      Case -6: DeleteSupProfile
      Case -7: frmUpdateServiceView.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      Case -8: AddPBSMappings        '15Nov11 TH Ported was -7,-9 so this needs reworking now if we ever port settings from 9.9 !!!!!!
      Case -9: DeletePBSMappings     '      "
      '15Nov11 TH Added New PCT Views
      Case -10: AddPCTMappings
      Case -11: ViewPCTMappings
      Case -12: DeletePCTMappings
      Case -13: SetPCTPrimaryIngredient
      Case -14: dummy = SendRobotProductData(d)    '20Jul12 CKJ added
      Case -15: dummy = PrintShelfLabel(d)         '   "
      Case Else 'no action
   End Select

End Sub

Sub StructToArray()
'2Mar97 CKJ Changed  Left$(LTrim$(Str$(d.xxx)) + Space$(9), 9) to format$(d.xxx)
'23Nov98 TH added extra drug elements(lastissued,lastordered,loccode2)
'25Nov98 TH added created & modified fields
'23Feb99 TH changed default setting
'13Aug01 SF added PIL2 field for CMI enhancement
'08Jan02 TH added StripSize for Pyxis enhancement
'07Apr10 AJK New fields ported from v8 for F0072782 and F0072542
'14Apr10 AJK Added fields for F0072782
'13Jun13 TH  Added ExpiryWarnDays (TFS 39884)

Dim valid%
Dim lErrNo As Long
Dim sErrDesc As String
Const ErrSource = "StructToArray"

   On Error GoTo ErrHandler

   presentent$(1) = d.Code
   presentent$(2) = d.LabelDescription    ' presentent$(2) = d.Description  XN 4Jun15 98073 New local stores description
   presentent$(3) = d.tradename
   presentent$(4) = d.cost
   presentent$(5) = d.contno
   presentent$(6) = d.supcode
   presentent$(7) = d.altsupcode
   presentent$(8) = d.ledcode
   presentent$(9) = Trim$(d.SisCode)    '11Jul97 CKJ Added trim for 6 char codes
   presentent$(10) = d.barcode
   presentent$(11) = d.cyto
   presentent$(12) = d.civas
   presentent$(13) = d.formulary
   Parsebnfcode d.bnf    '16Aug93 CKJ Added
   presentent$(14) = d.bnf
   presentent$(15) = d.warcode
   presentent$(16) = d.inscode
   presentent$(17) = d.dircode
   presentent$(18) = d.labelformat
   presentent$(19) = Format$(d.expiryminutes)
   presentent$(20) = UCase$(d.sisstock)
   presentent$(21) = d.LeadTime
   presentent$(22) = d.reorderpcksize
   presentent$(23) = d.PrintformV
   presentent$(24) = d.minissue
   presentent$(25) = d.maxissue
   presentent$(26) = d.reorderlvl
   presentent$(27) = d.reorderqty
   presentent$(28) = d.convfact
   presentent$(29) = d.anuse
   presentent$(30) = d.message
   presentent$(31) = d.therapcode
   presentent$(32) = d.extralabel
   presentent$(33) = d.stocklvl
   presentent$(34) = d.sislistprice
   presentent$(35) = d.contprice
   presentent$(36) = d.livestockctrl
   presentent$(37) = d.loccode
   'presentent$(38) = d.datelastperiodend
   parsedate d.datelastperiodend, presentent$(38), "1-", valid  '12Apr97 CKJ ddmmyy -> dd/mm/ccyy
   presentent$(39) = Format$(d.safetyfactor)
   presentent$(40) = Format$(d.usagedamping)
   presentent$(41) = Format$(d.usethisperiod) 'changed from d.perioduse 25.03.92
   presentent$(42) = d.inuse
   presentent$(43) = Format$(d.mlsperpack)
   presentent$(44) = d.recalcatperiodend
   presentent$(45) = Format$(d.lossesgains)
   presentent$(46) = d.ordercycle
   presentent$(47) = Format$(d.cyclelength)
   presentent$(48) = Format$(d.outstanding)
   presentent$(49) = UCase$(d.vatrate)  '23Dec93 CKJ mod
   presentent$(50) = d.DosingUnits      ' " 50-54 new
   presentent$(51) = Format$(d.dosesperissueunit)
 '!!**  presentent$(52) = Left$(LTrim$(Str$(d.WorksheetNo)) + Space$(5), 5)
   presentent$(53) = UCase$(d.ATC)
   presentent$(54) = UCase$(d.ATCCode)
   presentent$(55) = UCase$(d.UserMsg)                 '16Mar94 CKJ added
   presentent$(56) = Format$(d.ReconVol)               '29Mar94 ASC CIVAS
   presentent$(57) = UCase$(d.ReconAbbr)
   presentent$(58) = Format$(d.mgPerml)
   presentent$(59) = Format$(d.MaxmgPerml)
   presentent$(60) = Format$(d.MinmgPerml)
   presentent$(61) = UCase$(d.Diluent1Abbr)
   presentent$(62) = UCase$(d.Diluent2Abbr)
   presentent$(63) = UCase$(d.IVcontainer)
   presentent$(64) = Format$(d.DisplacementVolume)     'to here 29Mar94 ASC
   presentent$(65) = Format$(d.InfusionTime)
   presentent$(66) = Format$(d.MaxInfusionRate)        '<-to here 29Mar94 ASC
   presentent$(67) = Format$(d.PILnumber)              '13Jun94 CKJ added
   presentent$(68) = d.warcode2                        '20Mar95 CKJ added
   presentent$(69) = d.deluserid                       ' 1Mar97 CKJ added
   presentent$(70) = d.indexed                         '27Jun97 CKJ added
   presentent$(71) = d.lastreconcileprice              '   "
   presentent$(72) = d.local                           '17Jul97 CKJ Added  *7
   presentent$(73) = Format$(d.MinDailyDose)           '   "               Single
   presentent$(74) = Format$(d.MaxDailyDose)           '   "               Single
   presentent$(75) = Format$(d.MinDoseFrequency)       '   "               Single
   presentent$(76) = Format$(d.MaxDoseFrequency)       '   "               Single
   ''presentent$(77) = d.route                           '   "               *20
   presentent$(78) = d.chemical                        '   "               *50
   ''presentent$(79) = Format$(d.DosesPerAdminUnit)      '22Sep97 SF  added  *5
   ''presentent$(80) = d.adminunit                       '22Sep97 SF  added  Double
   presentent$(81) = d.DPSform                         '12Dec97 CKJ adedd  *25
   presentent$(82) = d.storesdescription               '29Dec97 EAC added *56
   presentent$(83) = d.storespack                      '29Dec97 EAC added *5
   presentent$(84) = Format$(d.teamworkbtn)            '29Dec97 EAC added integer
   'presentent$(85) = Format$(d.teamworkbtn)
   presentent$(86) = Format$(d.loccode2)               '23Nov98 TH added * 3
   presentent$(87) = Format$(d.lastissued)             '23Nov98 TH added * 8
   presentent$(88) = Format$(d.lastordered)            '23Nov98 TH added * 8
   presentent$(89) = d.CreatedUser                     '25Nov98 Th added *3
   presentent$(90) = d.createdterminal                 '25Nov98 Th added *15
   presentent$(91) = d.createddate                     '25Nov98 Th added *8
   presentent$(92) = d.createdtime                     '25Nov98 Th added *6
   presentent$(93) = d.modifieduser                    '25Nov98 Th added *3
   presentent$(94) = d.modifiedterminal                '25Nov98 Th added *15
   presentent$(95) = d.modifieddate                    '25Nov98 Th added *8
   presentent$(96) = d.modifiedtime                    '25Nov98 Th added *6
   presentent$(97) = d.batchtracking                   '22Dec98 CFY Added
   If Trim$(d.pflag) = "" Then d.pflag = "Y"                   '23Feb99 TH changed default setting
   presentent$(98) = UCase$(d.pflag)                           '01Feb99 TH Added *1
   presentent$(99) = UCase$(d.issueWholePack)          '23Feb99 SF added
   ''presentent$(100) = UCase$(d.HasFormula)             '11Oct99 CKJ added
   ' kinetics
   presentent$(116) = d.PIL2                           '13Aug01 SF added for CMI enhancement
   presentent$(117) = d.StripSize                      '08Jan02 TH added for Pyxis enhancement
    
   presentent$(118) = Trim$(d.pipcode)                 '02May02 ATW Added extra code fields
   presentent$(119) = Trim$(d.MasterPip)
   presentent$(120) = Iff(d.LabelInIssueUnits, "Y", "N")
   presentent$(121) = Iff(d.CanUseSpoon, "Y", "N")
   presentent$(122) = Trim$(d.PhysicalDescription)
   '07Apr10 AJK Ported in from v8 for (F0072782 and F0072542)
   presentent$(123) = d.DDDValue
   presentent$(124) = d.DDDUnits
   presentent$(125) = d.UserField1
   presentent$(126) = d.UserField2
   presentent$(127) = d.UserField3
   presentent$(128) = d.HIProduct
   '14Apr10 AJK Added fields for F0072782
   presentent$(129) = d.EDILinkCode
   presentent$(130) = d.PASANPCCode
   presentent$(131) = Iff(d.PNExclude, "Y", "N")   '27Jan12 CKJ
   presentent$(132) = "OK"                         '12Jul12 CKJ
   presentent$(133) = "Edit"                       '17Jul12 CKJ
   presentent$(134) = Iff(d.EyeLabel, "Y", "N")    '24Feb13 TH Changes ready for Merge
   presentent$(135) = Iff(d.PSOLabel, "Y", "N")    '07Aug12 TH '24Feb13 TH Changed array number
   presentent$(136) = Format$(d.ExpiryWarnDays)    '13Jun13 TH Added (TFS 39884)
Exit Sub
   
ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   '
   On Error GoTo 0
   If lErrNo = 9 Then 'Subscript out of range - this is most likely a settings problem
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc & crlf & "Please check that the Configuration settings for the number and detail of product fields are correct."
   
   Else
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If

   

End Sub
Sub Parsebnfcode(bnf$)
'-----------------------------------------------------------------------------
'16Aug93 CKJ Written
'Takes bnfcode as typed and parses on dots. Single digits become 0 prefixed.
' 1.2.3  => 01.02.03
' 1.12.3 => 01.12.03
' but longer entries remain untouched eg 123. 456.2 => 123.456.02
'-----------------------------------------------------------------------------

ReDim param(10) As String
Dim linetoparse$, linelen%, Ins%, numargs%, count%, ch%              '28Jul99 AE Dim'd variable

   linetoparse$ = Trim(bnf$)
   linelen = Len(linetoparse$)
   Ins = False
   numargs = 0
                                ' parse line into array
   For count = 1 To linelen
       ch = Asc(Mid$(linetoparse$, count))
       If ch = 46 Then    '.'
            Ins = False
         Else
            If Not Ins Then
                  numargs = numargs + 1
                  If numargs = 10 Then      ' param(10) contains the remainder
                        param(numargs) = Mid$(linetoparse$, count)
                        Exit For
                     End If
                  Ins = True
               End If
            param(numargs) = param(numargs) + Chr$(ch)
         End If
   Next             '14Feb95 CKJ removed count

   bnf$ = ""                    ' use parsed array
   For count = 1 To numargs
      param(count) = Trim(param(count))
      If Len(param(count)) = 1 Then bnf$ = bnf$ + "0"         ' add leading 0
      bnf$ = bnf$ + param(count)                              ' then digit(s)
      If count < numargs Then bnf$ = bnf$ + "."               ' and a dot
   Next
   Erase param

End Sub
Sub Checkdrug(ByVal positionPtr&, passed%, txt$)    ' 01Jun02 ALL/ATW added Ptr for clarity
'-----------------------------------------------------------------------------
' 8Feb95 CKJ Removed one check
'20Mar95 CKJ Added 2nd warning code
' 8Apr97 CKJ Added txt$ parameter, removed popmessagecr
'27Jun97 CKJ Duplicates are now permitted without warning
'17Jul97 CKJ Added Local Code
'12Dec97 CKJ Added option to disable the 'copy warning code' message
'            In stkmaint.ini, set [maintenance] AskCopyWarningCode=N (or F,0 etc)
'            If line is absent it will ask anyway
'06Aug98 CKJ Allow duplicate local codes if stkmaint.ini [Data] LocalCodeUnique=F
'            Defaults to unique if line absent. Valid entries T,F,Y,N,0,1,-1
'            Corrected use of IsInUse$
'19Feb99 CFY Extra validation added for the following fields: Formulary, BNF Code,
'            Start of Period, In Use, Live Stock, Infuse over minutes
'26Apr99 CFY Now inserts a valid Start of Period date when copying a drug.
'21May99 TH  Removed check on price to allow for Zero price items (free goods)
'17May99 CFY Corrected check on infusion rate as was previously checking filed 64 not 65
'14Sep00 SF/MMA allow hours,days,weeks to be specified
'20Sep00 MMA/SF Added to allow fractions of a day, hour or week
'30Sep08 CKJ prevent zero d/m/y in start of period (F0024926)
'01oct08 CKJ prevent zero in pack size (merged from V8)  (F0029065)
'14Apr10 AJK F0042865 Added check for "-" being entered and cleaned up cost validation
'20Apr10 AJK F0077124 Added NSV checks and rsCheck tidyup
'26Aug10 AJK F0042865 Added extra cost validation checks

'!!** needs more checks adding
' need to consider if reorderqty=0 is valid
' need to consider if reorderlvl=0 is valid
'-----------------------------------------------------------------------------
Dim s$, tmp$, sispassed%, X%, testchar%, badcheck%, findPtr&, found%, localpassed% ' 01Jun02 ALL/ATW find = findPtr
Dim IsInUse$
Dim i%, valid, ParsedDate$       '19Feb99 CFY Added
Const Stkmaint$ = "\Stkmaint.ini"
Dim dcop As DrugParameters
Dim strDesc As String
Dim rsCheck As ADODB.Recordset
Dim strSite As String
Dim strParam As String
Dim lngDSSMasterSiteID As Long
Dim DateFormat As String         '30sep08 ckj
Dim strCost As String '26Aug10 AJK F0042865

Const CHECK_ASCCODE = 0


   passed% = True
   s$ = ""

   If Len(LTrim$(presentent$(68))) = 0 Then         '2y warning code
      If Len(LTrim$(presentent$(15))) <> 0 Then  '1y warning code
         If TrueFalse(TxtD$(dispdata$ & Stkmaint$, "Maintenance", "Y", "AskCopyWarningCode", 0)) Then  '12Dec97 CKJ Added
            tmp$ = "Y"
            k.helpnum = 0
            Confirm "Second Warning Code is Blank", "copy warning to second warning code", tmp$, k
            If Not k.escd And tmp$ = "Y" Then
               presentent$(68) = presentent$(15)
               d.warcode2 = presentent$(15)
            End If
            If k.escd Then passed = False
            k.escd = False    '13Jun98 ASC
         End If
      End If
   End If

   If Trim$(presentent$(2)) = "" Then               'Drug name
      s$ = s$ & "Description not entered" & cr
   End If

   'If Val(presentent$(4)) <= 0 Then                 'Issue price                                                                                                    '21May99 TH Removed check on price
   '14Apr10 AJK F0042865 Added check for "-" being entered and cleaned up cost validation
   '   If Val(presentent$(4)) < 0 Or Trim$(presentent$(4)) = "" Or (Trim$(presentent$(4)) <> "" And InStr((presentent$(4)), "0") = 0 And Val(presentent$(4)) < 0) Then   'to allow for free goods
   '26Aug10 AJK F0042865 Added extra checks
   strCost = Trim$(presentent$(4))
   If Val(presentent$(4)) < 0 Or Trim$(presentent$(4)) = "" Then   'to allow for free goods
      s$ = s$ & "Cost not entered" & cr
   'end if
   ElseIf Trim$(presentent$(4)) = "-" Or Trim$(presentent$(4)) = "." Then
      s$ = s$ & "Invalid cost entered" & cr
   Else
      replace strCost, " ", "", 0
      replace strCost, ".", "", 0
      replace strCost, "-", "", 0
      If Len(strCost) = 0 Then
         s$ = s$ & "Invalid cost entered" & cr
      End If
   End If
   
      

   If Len(LTrim$(presentent$(6))) <= 0 Then         'Supplier code
      s$ = s$ & "Supplier code not entered" & cr
   End If

   'If Len(presentent$(9)) = 7 Then
   '      sispassed = True                           'NSV code   '!!** Should use mask
   '      For x = 1 To 7          'extra checking added 22.04.92
   '         testchar = Asc(UCase$(Mid$(presentent$(9), x, 1)))
   '         If (x < 4 Or x = 7) And (testchar < 65 Or testchar > 90) Then sispassed = False
   '         If (x > 3 And x < 7) And (testchar < 48 Or testchar > 57) Then sispassed = False
   '      Next
   '   Else
   '      sispassed = False
   '   End If
   sispassed = PatternMatch(presentent$(9), NSVpattern$())      '12Jul97 CKJ Replaced fixed pattern
   If Not sispassed Then s$ = s$ & "NSV code not entered or incorrect" & cr
                                                    
   If Len(Trim$(presentent$(72))) Then                          '17Jul97 CKJ OK to be ""
      localpassed = PatternMatch(presentent$(72), LocalPattern$())  '06Aug98 CKJ No change for unrestricted local codes
   End If

   If Len(Trim$(presentent$(10))) < 13 Then s$ = s$ & "Barcode not entered" & cr
   'If Val(presentent$(28)) <= 0 Then:                                                 '01oct08 CKJ merged from V8  (F0029065)
   If Val(presentent$(28)) <= 0 Then s$ = s$ & "Re-order pack size not entered" & cr   '   "
   If Len(Trim$(presentent$(27))) = 0 Then s$ = s$ & "Re-order quantity not entered" & cr
   If Len(Trim$(presentent$(23))) = 0 Then s$ = s$ & "Issue units not entered" & cr
   If Len(Trim$(presentent$(24))) = 0 Then s$ = s$ & "Minimum Issue not entered" & cr
   If Len(Trim$(presentent$(25))) = 0 Then s$ = s$ & "Maximum Issue not entered" & cr
   If UCase$(presentent$(36)) = "Y" And (Val(presentent$(26)) < 0 Or Trim$(presentent$(26)) = "") Then
      s$ = s$ & "Re-order level not entered and stock control is live" & cr
   End If

   If Val(presentent$(39)) <= 0 Then                'safety factor default
      d.safetyfactor = 1.2
      presentent$(39) = "1.2"
      s$ = s$ & "Safety factor missing: Setting to 1.2 as default" & cr
   End If

   If Val(presentent$(40)) <= 0 Then                'usage damping default
      d.usagedamping = 0.75
      presentent$(40) = ".75"
      s$ = s$ & "Usage damping missing: Setting to 0.75 as default" & cr
   End If

   If Len(LTrim$(presentent$(49))) = 0 Then s$ = s$ & money$(9) & " rate not entered" & cr
   
   '01Mar07 TH Added
   If d.DSSMasterSiteID = 0 Then
      strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
   Else
      lngDSSMasterSiteID = d.DSSMasterSiteID
   End If
   '-------------
   
   dcop = d

   d.Code = presentent$(1)                          'check look up code
   d.LabelDescription = presentent$(2)   ' d.Description = presentent$(2)  XN 4Jun15 98073 New local stores description
   'IsInUse$ = " already in use by " & Trim$(d.description) & cr '12Dec97 CKJ reduced duplication
   IsInUse$ = " already in use by " '06Aug98 CKJ Corrected. It has to use description after lookup
   badcheck = 2
   ''checkcode d, badcheck
   checkcode badcheck
   If badcheck Then
      's$ = s$ & "Look up code missing or not of form (4 letters)(4 numbers)" & cr  '08Feb99 CFY
      s$ = s$ & "Look up code missing or invalid" & cr                              '08Feb99 CFY
   Else
      '27Jun97 CKJ Duplicates are now permitted without warning
      If CHECK_ASCCODE Then
''         findPtr& = 0
''         findrdrug presentent$(1), 1, d, findPtr&, found, 2, False
''         'If find <> position And find <> 0 And found Then
''         'If (findPtr& <> positionPtr&) And (findPtr <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
''         If (d.productstockID <> positionPtr&) And (findPtr <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
''            s$ = s$ & "RE-ENTER look up code:" & cr & presentent$(1) & IsInUse$ & Trim$(d.Description) & cr  '06Aug98 CKJ corrected
''         End If
         
         strParam = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                    gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, (presentent$(1)))

         Set rsCheck = gTransport.ExecuteSelectSP(g_SessionID, "pWProductCheckbyCodeandDSSMasterSiteID", strParam)
         If Not rsCheck Is Nothing Then     'use returned recordset
            If rsCheck.State = adStateOpen Then
               If rsCheck.RecordCount <> 0 Then
                  If dcop.SiteProductDataID <> rsCheck!SiteProductDataID Then
                     'Get Description and throw the warning
                     'strDesc = Trim$(rsCheck!storesdescription)
                     'If strDesc = "" Then strDesc = Trim$(rsCheck!Description)    XN 4Jun15 98073 New local stores description
                                         strDesc = Trim$(rsCheck!Description)
                     plingparse strDesc, "!"
                     'get a list of sites
                     strSite = ""
                     rsCheck.MoveFirst
                     Do While Not rsCheck.EOF
                        strSite = strSite & Trim$(rsCheck!SiteDescription) & ","
                        rsCheck.MoveNext
                     Loop
                     If Len(strSite) Then strSite = Left(strSite, Len(strSite) - 1) 'Get rid of last comma
                     s$ = s$ & "RE-ENTER look up code:" & cr & presentent$(1) & IsInUse$ & Trim$(strDesc) & " in " & strSite & cr   '06Aug98 CKJ corrected
                  End If
               End If
            End If
         End If
      End If
   End If

   '20Apr10 AJK F0077124 Added NSV checks
   If sispassed Then
      Set rsCheck = GetProductRSByNSV(presentent$(9))
      Do Until rsCheck.EOF = True
         'Found products with the same NSVCode
         If d.DrugID = 0 Then
            'Unsaved brand new product, will have generated DrugID as another product with the same NSV
            s$ = s$ & "NSVCode in use for a different product" & cr
            Exit Do
         ElseIf rsCheck("ProductStockID") <> d.productstockID And rsCheck("DrugID") <> d.DrugID Then
            'Attempting to save the product as an NSVCode in use by a different DrugID
            s$ = s$ & "NSVCode in use for a different product" & cr
            Exit Do
         End If
         rsCheck.MoveNext
      Loop
      If d.DrugID > 0 Then
         'This product has been edited or imported
         Set rsCheck = GetProductRSByDrugID(d.DrugID)
         Do Until rsCheck.EOF = True
            'Found products with the same DrugID
            If rsCheck("ProductStockID") <> d.productstockID And rsCheck("siscode") <> presentent$(9) Then
               'Product has same DrugID, different ProductStockID and different NSVCode
               s$ = s$ & "Product in use for a different NSVCode" & cr
            End If
            rsCheck.MoveNext
         Loop
      End If
   End If
   
   

''   If sispassed Then                                'check NSV code
''         findPtr& = 0
''         findrdrug (presentent$(9)), 1, d, findPtr&, found, 2, False
''         'If find <> position And find <> 0 And found Then
''         'If (findPtr& <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW ?  this expression used many times ? function breakout to prevent future F**kup?
''         If (d.productstockID <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW ?  this expression used many times ? function breakout to prevent future F**kup?
''               s$ = s$ & "RE-ENTER NSV code:" & cr & presentent$(9) & IsInUse$ & Trim$(d.Description) & cr '06Aug98 CKJ corrected
''            End If
''      End If

   If localpassed Then                              'check Local code 17Jul97 CKJ Added
      If TrueFalse(TxtD$(dispdata$ & Stkmaint$, "Data", "T", "LocalCodeUnique", 0)) Then  '06Aug98 CKJ Added. Allows duplicate local codes
         findPtr& = 0
         findrdrug (presentent$(72)), 1, d, findPtr&, found, 2, False, False
         'If find <> position And find <> 0 And found Then
         'If (findPtr& <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
         If (d.productstockID <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
            's$ = s$ & "RE-ENTER Local code:" & cr & presentent$(72) & IsInUse$ & Trim$(d.Description) & cr   XN 4Jun15 98073 New local stores description
                        s$ = s$ & "RE-ENTER Local code:" & cr & presentent$(72) & IsInUse$ & Trim$(d.LabelDescription) & cr   '06Aug98 CKJ corrected
         End If
      End If
   End If

   If Len(Trim$(presentent$(10))) = 13 Then         'check barcode
''         findPtr& = 0                                                 ' 01Jun02 ALL/ATW
''         findrdrug (presentent$(10)), 1, d, findPtr&, found, 2, False           ' 01Jun02 ALL/ATW
''         'If find <> position And find <> 0 And found Then
''         'If (findPtr& <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
''         If (d.productstockID <> positionPtr&) And (findPtr& <> 0) And (found <> 0) Then ' 01Jun02 ALL/ATW
''               s$ = s$ & "RE-ENTER barcode:" & cr & presentent$(10) & IsInUse$ & Trim$(d.Description) & cr   '06Aug98 CKJ corrected
''            End If

      '01Mar07 TH Now we must check across the entire DSS Site '
         
      strParam = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                 gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, dcop.SiteProductDataID) & _
                 gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, (presentent$(10)))

      Set rsCheck = gTransport.ExecuteSelectSP(g_SessionID, "pWProductCheckForBarcodeDuplication", strParam)
      If Not rsCheck Is Nothing Then     'use returned recordset
         If rsCheck.State = adStateOpen Then
            If rsCheck.RecordCount <> 0 Then
               'If dcop.SiteProductDataID <> rsCheck!SiteProductDataID Then
                  'Get Description and throw the warning
                  'strDesc = Trim$(rsCheck!storesdescription)
                  'If strDesc = "" Then strDesc = Trim$(rsCheck!Description)   XN 4Jun15 98073 New local stores description
                                  strDesc = Trim$(rsCheck!Description)
                  plingparse strDesc, "!"
                  'get a list of sites
                  strSite = ""
                  rsCheck.MoveFirst
                  Do While Not rsCheck.EOF
                     'If dcop.SiteProductDataID <> rsCheck!SiteProductDataID Then
                     strSite = strSite & Trim$(rsCheck!SiteDescription) & ","
                     'End If
                     rsCheck.MoveNext
                  Loop
                  If Len(strSite) Then
                     strSite = Left(strSite, Len(strSite) - 1) 'Get rid of last comma
                     s$ = s$ & "RE-ENTER barcode:" & cr & presentent$(10) & IsInUse$ & Trim$(strDesc) & " in " & strSite & cr   '06Aug98 CKJ corrected
                  End If
               'End If
            End If
         End If
      End If
   End If

   '---------------------------Enter dummy barcode if blank---------------------
   If Trim$(presentent$(10)) = "" And Trim$(presentent$(9)) <> "" Then
      s$ = s$ & "Barcode not entered: Dummy barcode created" & cr
      dummyEAN presentent$(9), presentent$(10)
   End If

   If UCase$(presentent$(12)) = "Y" Then            'CIVAS item
      If Len(LTrim$(presentent$(50))) = 0 Then   'dosing units
         s$ = s$ & "CIVAS: Dosing units not entered" & cr
      End If
      If Val(presentent$(51)) = 0 Then           'dosesperissueunit
         s$ = s$ & "CIVAS: Doses per issue unit not entered" & cr
      End If
      If Val(presentent$(58)) = 0 Then           'mgperml
         s$ = s$ & "CIVAS: Final dose units/ml not entered" & cr
      End If
      If Val(presentent$(59)) = 0 Then           'maxmgperml
         s$ = s$ & "CIVAS: Maximum dose units/ml not entered" & cr
      End If
      If Val(presentent$(60)) = 0 Then           'minmgperml
         s$ = s$ & "CIVAS: Minimum dose units/ml not entered" & cr
      End If
      '14Sep00 SF/MMA allow hours,days,weeks to be specified
      'If Not IsDigits(presentent$(65)) Then       'Infuse in minutes       '19Feb99 CFY Added      '17Jun99 CFY Was previously checking field 64
      tmp$ = Trim$(UCase$(presentent$(65)))
      replace tmp$, "H", "", False
      replace tmp$, "D", "", False
      replace tmp$, "W", "", False
      replace tmp$, ".", "", False         '20Sep00 MMA/SF Added to allow fractions of a day, hour or week
      If Not IsDigits(tmp$) Then
      '14Sep00 SF/MMA -----
         s$ = s$ & "CIVAS: Infuse in minutes is non-numeric" & cr       '         "
      End If                                                            '         "
      
      '8Feb95 CKJ Commented out; whilst advisable, these are not compulsory
      'IF VAL(presentent$(56)) + VAL(presentent$(64)) = 0 THEN  'recon vol + displacement vol
      '      s$ = s$ & "CIVAS: Either displacement or reconstitution volume must be entered"&cr
      '   END IF
   End If

   '----------------If live check reorder pack sizes etc.-----------------------
   If Trim$(presentent$(13)) = "" Then                   'Formulary           '19Feb99 CFY Added
      s$ = s$ & "'Formulary' flag not set" & cr                            '         "
   End If                                                                  '         "
                                                                              '         "
   i% = 1                                                'BNF Code            '         "
   Do                                                                         '         "
      valid% = (InStr("0123456789.", Trim$(Mid$(presentent$(14), i, 1))) > 0) '         "
      i% = i% + 1                                                             '         "
   Loop While i <= Len(presentent$(14)) And valid%                            '         "
   If Not valid% Then                                                      '         "
      s$ = s$ & "BNF Code is invalid." & cr                                '         "
   End If                                                                  '         "
                                                                       
   'parsedate presentent$(38), ParsedDate$, "1", valid%   'Start of Period                '30Sep08 CKJ prevent zero d/m/y  (F0024926)
   DateFormat = "1"                                                                       '   "
   parsedate presentent$(38), ParsedDate$, DateFormat, valid%   'Start of Period          '   "
   If DateFormat = "0" Then valid = False                                                 '   "
   If valid% Then                                                          '         "
      presentent$(38) = ParsedDate$                                        '         "
   Else                                                                    '         "
      s$ = s$ & "Start of Period contains invalid date" & cr               '         "
   End If                                                                  '         "
                                                                           '         "
   If Trim$(presentent$(42)) = "" Then                   'In use           '         "
      s$ = s$ & "'In Use' flag not set" & cr                               '         "
   End If                                                                  '         "
                                                                           '         "
   If Trim$(presentent$(36)) = "" Then                   'Live Stock       '         "
      s$ = s$ & "'Live Stock' flag not set" & cr                           '         "
   End If                                                                  '         "

   d = dcop

   If Len(s$) Then passed = False

   txt$ = s$
   
   '20Apr10 AJK F0077124 Added tidyup
   If Not rsCheck Is Nothing Then Set rsCheck = Nothing

End Sub
Sub getorderno(edittype, orderno As Long, incr%)
'ASC 27Mar91
'ASC 10Apr93 Stop reading locked record but return last orderno
'            Gets order number, requisition and return number
'02Dec98 TH  New delno.dat file to record reprint numbers for delivery notes accessed with edittype 25

'incr% = 0 READ
'incr% = -1 INCREMENT
'incr% = 1 DECREMENT
'incr% = 2 WRITE
'incr% = 3 LOCK
'incr% = 4 UNLOCK

Static lastincr%, lastorderno As Long

Dim temp$, pointer&
          
   If incr = 0 And lastincr = 3 Then
      orderno = lastorderno
      Exit Sub
   End If

   Select Case edittype
      Case 1, 2, 3
         temp$ = "\orderno"
      Case 5, 6, 7, 8
         temp$ = "\reqno"
      Case 9
         temp$ = "\retno"
      Case -1  'Adjustments
         temp$ = "\adjust"
      Case 25  'del notes
         temp$ = "\delno"
      Case 4
         temp$ = "\dispnote"
   End Select

   pointer& = orderno
   GetPointerSQL dispdata$ + temp$ + ".dat", pointer&, incr%

   If pointer& > 2147483647 And incr < 3 Then 'SQL Upper limit of long, I guess you never know !
      pointer& = 1
      GetPointerSQL dispdata$ + temp$ + ".dat", pointer&, 2
   End If
   orderno = pointer&
   lastorderno = orderno
   lastincr = incr

End Sub
Function PresentPrescriptionID() As Long
'Stubbage
PresentPrescriptionID = 0
End Function
Sub dummyEAN(ip As String, op As String)
'Create pseudo EAN code from NSVcode
'ABC123D' becomes '65 66 67 123 68 0 x' where x is the calculated check digit
' 8Mar97 CKJ Modified to accept any combination of alphanumerics, with the
'            proviso that the total number of digits needed is 12 or less

Dim tmpint  As Integer
Dim strIn As String
Dim intCount As Integer

   op = ""
   If Len(ip) = 7 Then
      strIn = UCase$(ip)
      For intCount = 1 To 7
         tmpint = Asc(Mid$(strIn, intCount, 1))           'ASCII value of character
         Select Case tmpint
            Case 48 To 57: op = op & Chr$(tmpint)    '0 to 9      0-9 unchanged
            Case Else:     op = op & Format$(tmpint) 'A to Z etc  A -> 65
            End Select
      Next
      op = Left$(op & String$(12, "0"), 12)       'pad to 12 digits if necessary
      op = op & eanaddchkdigit$(op)
   End If
   
End Sub
Function eanaddchkdigit(ip As String) As String
'-----------------------------------------------------------------------------
'  take 12 digits as string & find the check digit
' 4Mar97 CKJ Procedure copied from EAN.BAS to avoid including more than needed
'-----------------------------------------------------------------------------
Dim i%, chk%
ReDim ean(1 To 12)

   eanaddchkdigit$ = ""
   If Len(ip) = 12 Then
      For i = 1 To 12
         ean(i) = Val(Mid$(ip, i, 1))
      Next i

      chk = 0
      
      For i = 2 To 12 Step 2
         chk = chk + ean(i)
      Next i
      
      chk = chk * 3
      chk = chk Mod 10
      
      For i = 1 To 11 Step 2
         chk = chk + ean(i)
      Next i
      
      chk = chk Mod 10
      chk = (10 - chk) Mod 10
      If chk < 0 Then chk = chk + 10
      eanaddchkdigit$ = Right$(Str$(chk), 1)
   Else
      Beep   ' not 12 digits
   End If

End Function

Sub ChooseDosingUnits(Code$, desc$)
'11Apr97 CKJ Procedure written - crude but simple
'09feb00 VS/MMA/SF parses out ; when displaying dosing units

Dim found&, cont&, txt$, success%, tmp$, r1%, r2%, r3%
Dim strParams As String
Dim rsDosingUnits As ADODB.Recordset

   
   On Error Resume Next
   Screen.MousePointer = HOURGLASS
   ''GetTextFile dispdata$ + "\patmed.ini", txt$, success%   '14Jul98 CKJ NC
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
   Set rsDosingUnits = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyGetDosingUnitsbySiteID", strParams)
   If Not rsDosingUnits Is Nothing Then     'use returned recordset
      If rsDosingUnits.State = adStateOpen Then
         If rsDosingUnits.RecordCount <> 0 Then
            If Not rsDosingUnits.EOF Then
               rsDosingUnits.MoveFirst
               
               Do While Not rsDosingUnits.EOF
                  tmp$ = Left$(RtrimGetField(rsDosingUnits!key), (InStr(UCase$(Trim$(RtrimGetField(rsDosingUnits!key))), "INSTRUCT") - 1))
                  If LCase$(tmp$) <> "spoon" Then
                  LstBoxFrm.LstBox.AddItem "  " & tmp$
                  End If
                  rsDosingUnits.MoveNext
               Loop
            End If
         End If
      End If
   End If
''   replace txt$, lf, "", 0
''   r1 = 0   'points to last cr
''   r2 = 0   'points to next cr
''   r3 = 0   'points to start of INSTRUCT text
''   Do While r2 <= Len(txt$)
''      r2 = InStr(r2 + 1, txt$, cr)
''      If r2 Then                                           '      v----v
''            tmp$ = Mid$(txt$, r1 + 1, r2 - r1 - 1)         '  x...x....x...x
''            r3 = InStr(UCase$(tmp$), "INSTRUCT")
''            If r3 > 0 And Left$(tmp$, 1) <> "'" And Left$(tmp$, 5) <> "spoon" Then 'spoon is a kludge
''                  'LstBoxFrm.LstBox.AddItem "  " & Left$(tmp$, r3 - 1)                                '09feb00 VS/MMA/SF replaced this line
''                  If Left$(tmp$, 1) <> ";" Then LstBoxFrm.LstBox.AddItem "  " & Left$(tmp$, r3 - 1)   '09feb00 VS/MMA/SF
''               End If
''            r1 = r2
''         Else
''            Exit Do
''         End If
''   Loop
   Screen.MousePointer = STDCURSOR
   On Error GoTo 0
   
   LstBoxFrm.lblTitle = cr & "Choose Dosing Units" & cr
   LstBoxFrm.lblHead = "Dosing Units"
   LstBoxShow
   If LstBoxFrm.LstBox.ListIndex > -1 Then
         Code$ = Trim$(LstBoxFrm.Tag)
      Else
         Code$ = ""
      End If
   desc$ = "Shift-F1 for list"
   Unload LstBoxFrm
End Sub

Sub issue_callback()
'stubbage

End Sub
Sub GetLabelDetails(strLabelText As String, intBatchNumber As Integer, lngStartDate As Long)
'stubbage

End Sub

Sub SuppBarcodes(lngSiteProductDataID As Long)

Dim rsBarcodes As ADODB.Recordset
Dim strParams As String
Dim strAns As String
Dim intCount As Integer
'Dim lngDSSMasterSiteID As Long

''popmessagecr "", "This functionality is not yet available"


   ''Load Barcodes
   'TabStops(1) = 4 * 20
   'TabStops(2) = 4 * 30
   'LstBoxSetTabs Barcodes.lstBCR, 2, TabStops()
   'cont& = 0
   
   'Do
      'tofind$ = d.SisCode
      'strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      'lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
      'd.DSSMasterSiteID = lngDSSMasterSiteID
      
      strParams = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, lngSiteProductDataID)
      Set rsBarcodes = gTransport.ExecuteSelectSP(g_SessionID, "pWAlternativeBarcodesbySiteProductDataID", strParams)
   
      'binarysearchidx tofind$, suppBCR$, 1, cont&, found&
      'nsvcode  EAN 8/13   supp
      'AAANNNANNNNNNNNnnnnnSSSSS
      'maps to
      'NNNNNNNNnnnnn......SSSSS......dd-mm-yy
      
      If Not rsBarcodes.EOF Then
         rsBarcodes.MoveFirst
         Do While Not rsBarcodes.EOF
            Barcodes.lstBCR.AddItem RtrimGetField(rsBarcodes!Alias), intCount
            Barcodes.lstBCR.ItemData(intCount) = Int(GetField(rsBarcodes!SiteProductDataAliasID))
            intCount = intCount + 1
            rsBarcodes.MoveNext
         Loop
      End If
      rsBarcodes.Close
      Set rsBarcodes = Nothing
      'If found& Then
      '      If found& = 1 Then
      '            dat$ = Space$(6)  ' no date stored
      '         Else
      '            dat$ = Right$("000000" & Format$(found&), 6)   'date 'ddmmyy'
      '         End If
      '      Item$ = pad$(Mid$(tofind$, 8, 13), 13) & TB          'barcode  '27Jun97 CKJ Added Pad$
      '      Item$ = Item$ & pad$(Mid$(tofind$, 21, 5), 5) & TB   'supplier '   "
      '      Item$ = Item$ & Left$(dat$, 2) + "-" + Mid$(dat$, 3, 2) + "-" + Mid$(dat$, 5, 2)
      '      Barcodes.lstBCR.AddItem Item$, 0
      '   End If
   'Loop While cont&
      
         Barcodes.Tag = "0"
         Barcodes.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
        
''         If Barcodes.Tag = "-1" Then  'list was modified
''            strAns = "Y"
''            k.helpnum = 1120
''            Confirm "?Supplementary Barcodes", "save changes to list of barcodes", strAns, k
   
''            If ans$ = "Y" And Not k.escd Then
''               Do                 'Delete all existing barcodes for this drug
''                  tofind$ = d.SisCode
''                  binarysearchidx tofind$, suppBCR$, 1, 0, found&
''                  If found& Then
''                        Updateindex tofind$, "", (found&), suppBCR$, (failed)
''                     End If
''               Loop While found&
''
''               ReDim lines$(1 To 3)
''               For count = 1 To Barcodes.lstBCR.ListCount   'replace with new barcodes
''                  deflines (Barcodes.lstBCR.List(count - 1)), lines$(), TB, 1, numoflines
''                  newentry$ = d.SisCode & pad$(lines$(1), 13) & pad$(lines$(2), 5)
''                  dat$ = pad$(lines$(3), 8)
''                  replace dat$, "-", "", 0
''                  vector& = Val(dat$)
''                  If vector& = 0 Then vector& = 1
''                  Updateindex "", newentry$, vector&, suppBCR$, (failed)
''               Next
''               sortindex "", suppBCR$
''
''               mainBCR$ = dispdata$ + "\drugbcr.idx"
''               Do       'remove existing entries for this drug in drugBCR.idx
''                  tofind$ = d.SisCode
''                  binarysearchidx tofind$, mainBCR$, 1, 0, found&
''                  If found& Then
''                        Updateindex tofind$, "", (found&), mainBCR$, (failed)
''                     End If
''               Loop While found&
''
''               For count = 1 To Barcodes.lstBCR.ListCount ' add all entries
''                  tmp$ = Barcodes.lstBCR.List(count - 1)
''                  Updateindex "", Left$(tmp$, 13), (DrugPtr&), mainBCR$, (failed)  ' 01Jun02 ALL/ATW
''               Next
''
''               sortindex "", mainBCR$
''            End If
''         End If
         Unload Barcodes
         k.escd = False
         k.exitval = 0
     ' End If

End Sub
Public Sub PutRecordFailure(ByVal ErrNo As Integer, ByVal ErrDescription As String)
'Bye bye Baby bye bye
Dim blnResult As Boolean

   popmessagecr "", "A critical Error has occurred. This application can no longer continue"
   
  ' blnResult = UcPSEditor.RefreshState(g_SessionID, SiteNumber)
  'Need a way of closing the user control properly
  On Error Resume Next
  lstUC("Lstbox").Clear
  lstUC("Lstbox").Enabled = False
  lstUC("cmdAdd").Enabled = False
  lstUC("cmdEdit").Enabled = False
  lstUC("cmdCancel").Enabled = False
  g_SessionID = 0
  BlankWProduct d
  gProductID = 0
  On Error GoTo 0
  

End Sub

Public Sub SetPrimarySupplier()

Dim Numoflines%, i%, FoundSup As Long, success%, NumOfEntries%, found%, View%
Dim sup As supplierstruct
Dim SupProfile As TSupProfile
Dim ans$, txt$, Selected$
Dim seperator$                                  '06Jan00 AW added
Dim Vatview%
Dim invalidaltsup%        '25Jan00 TH
Dim strAltSups As String
Dim intAltSups As Integer
Dim blnAddNew As Boolean
Dim strSupCode As String
Dim strAns As String

ReDim Menu$(10), menuhlp%(10), supcode$(10)


   strAltSups = GetAltenativeSupplierString(d.SisCode)
   deflines d.altsupcode, supcode$(), seperator$, 1, Numoflines%             '         "
   If Numoflines <= 1 Then                                                   '         "
      seperator$ = ","                                                    '         "
      deflines strAltSups, supcode$(), seperator$, 1, Numoflines%       '         "
   End If                                                                 '         "
   If Numoflines >= 1 Then
      For i% = 1 To Numoflines%
         getsupplier supcode$(i), 0, FoundSup, sup
         If FoundSup Then
               'menu$(i + 1) = sup.code & TB & TB & sup.name                 '20Mar01 TH Replaced with below
               If UCase(Trim(d.supcode)) = UCase(Trim(sup.Code)) Then
                  'Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"
                  invalidaltsup = invalidaltsup + 1
               Else
                  Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name '    "
               End If
            Else                                                                                   '20Mar01 TH Added
               popmessagecr "", "Alternative Supplier " & supcode$(i) & " is not a valid supplier" '    "
               invalidaltsup = invalidaltsup + 1
            End If
      Next
      intAltSups = Numoflines% - (invalidaltsup)
      
      ''Menu$(intAddNew) = "Select New Primary SupplierSupplier Profile"
   End If
   If intAltSups > 0 Then
      Menu$(0) = "Select New Primary Supplier"
      inputmenu Menu$(), menuhlp%(), ans$, k
   Else
      popmessagecr "", "There are no alternative suppliers set up for this product"
      k.escd = True
   End If
   
   If Not k.escd Then
      strSupCode = Trim$(Left$(Menu$(Val(ans$)), 5))
      'getdrug d, d.productstockID, 0, True
      getdrugsup d, d.productstockID, 0, True, strSupCode
      d.WSupplierProfileID = -100 '04Feb06 TH Flag to ensure incorrect supplier profile info is not saved.
      d.supcode = strSupCode
      putdrug d
   End If
   
End Sub

Public Sub DeleteSupProfile()
Dim Numoflines%, i%, FoundSup As Long, success%, NumOfEntries%, found%, View%
Dim sup As supplierstruct
Dim SupProfile As TSupProfile
Dim ans$, txt$, Selected$
Dim seperator$                                  '06Jan00 AW added
Dim Vatview%
Dim invalidaltsup%        '25Jan00 TH
Dim strAltSups As String
Dim intAltSups As Integer
Dim blnAddNew As Boolean
Dim strSupCode As String
Dim strAns As String
Dim lngOK As Long

ReDim Menu$(10), menuhlp%(10), supcode$(10)


   strAltSups = GetAltenativeSupplierString(d.SisCode)
   deflines d.altsupcode, supcode$(), seperator$, 1, Numoflines%             '         "
   If Numoflines <= 1 Then                                                   '         "
      seperator$ = ","                                                    '         "
      deflines strAltSups, supcode$(), seperator$, 1, Numoflines%       '         "
   End If                                                                 '         "
   If Numoflines >= 1 Then
      For i% = 1 To Numoflines%
         getsupplier supcode$(i), 0, FoundSup, sup
         If FoundSup Then
            'menu$(i + 1) = sup.code & TB & TB & sup.name                 '20Mar01 TH Replaced with below
            If UCase(Trim(d.supcode)) = UCase(Trim(sup.Code)) Then
               'Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name & TB & "(Primary Supplier)"
               invalidaltsup = invalidaltsup + 1
            Else
               Menu$(i - invalidaltsup) = sup.Code & TB & TB & sup.name '    "
            End If
         Else                                                                                   '20Mar01 TH Added
            popmessagecr "", "Alternative Supplier " & supcode$(i) & " is not a valid supplier" '    "
            invalidaltsup = invalidaltsup + 1
         End If
      Next
      intAltSups = Numoflines% - (invalidaltsup)
      
      ''Menu$(intAddNew) = "Select New Primary SupplierSupplier Profile"
   End If
   If intAltSups > 0 Then
      Menu$(0) = "Select Supplier Profile to Delete"
      inputmenu Menu$(), menuhlp%(), ans$, k
   Else
      popmessagecr "", "There are no alternative suppliers set up for this product"
      k.escd = True
   End If
   
   If Not k.escd Then
      strSupCode = Trim$(Left$(Menu$(Val(ans$)), 5))
      'Confirm message
      GetSupProfile d.SisCode, strSupCode, SupProfile, success%, found%
      If found Then
         lngOK = gTransport.ExecuteDeleteSP(g_SessionID, "WSupplierProfile", SupProfile.WSupplierProfileID)
      End If
      'Delete the supplier profile
   End If
End Sub
Sub ReadLocalSites()
'22Apr07 TH Moved here from orderlibs to allow ref from prod stock editor
'17May10 AJK F0076258 Removed doneonce check as values are persisting across different controls in ICW

'Static doneonce
Dim sites$
Dim comma%, NumItems%, count%
Dim intMiss As Integer
   
'   If doneonce = False Then
'      doneonce = True
      sites$ = siteinfo$("SiteNumbers", "")
      If sites$ <> "" Then
         comma = InStr(sites$, ",")
         NumItems = 1                                'at least one other site
         
         Do While comma
            NumItems = NumItems + 1
            comma = InStr(comma + 1, sites$, ",")
         Loop
   
         ReDim localsitenos%(NumItems), localsiteabb$(NumItems), localsitepth$(NumItems)
        
         deflines sites$, localsitepth$(), ",(*)", 1, NumItems
         
         intMiss = 0
         
         'sites$ = siteinfo$("dispdataDRVs", "")
         'deflines sites$, localsitepth$(), ",(*)", 1, NumItems
         sites$ = siteinfo$("hospabs", "")
         deflines sites$, localsiteabb$(), ",(*)", 1, NumItems
         intMiss = 0
         For count = 1 To NumItems
            If (Val(localsitepth$(count)) = SiteNumber Or Val(localsitepth$(count)) = 999) Then
               intMiss = intMiss + 1
            Else
               localsitenos%(count - intMiss) = Val(localsitepth$(count))
               'localsitepth$(count - intMiss) = localsitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(localsitenos%(count))), 3)
               localsiteabb$(count - intMiss) = localsiteabb$(count)
            
            End If
         Next
''         For count = 1 To NumItems  ' example  G:\DISPDATA.003
''            If (Val(localsitepth$(count)) = SiteNumber Or Val(localsitepth$(count)) = 999) Then
''               intMiss = intMiss + 1
''            Else
''               localsitepth$(count - intMiss) = localsitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(localsitenos%(count))), 3)
''               localsiteabb$(count - intMiss) = localsiteabb$(count)
''            End If
''         Next
         ReDim Preserve localsitenos%(NumItems - intMiss), localsiteabb$(NumItems - intMiss), localsitepth$(NumItems - intMiss)
'      Else
'         ReDim localsitenos%(0), localsiteabb$(0), localsitepth$(0)
'      End If
      
      localsitenos%(0) = SiteNumber
      localsiteabb$(0) = hospabbr$
      localsitepth$(0) = dispdata$
   End If
   
   
End Sub
Sub ReadSites()
'22Apr07 TH Moved here from orderlibs to allow ref from prod stock editor
Static doneonce
Dim sites$
Dim comma%, NumItems%, count%

   
   If doneonce = False Then
      doneonce = True
      sites$ = siteinfo$("SiteNumbers", "")
      If sites$ <> "" Then
         comma = InStr(sites$, ",")
         NumItems = 1                                'at least one other site
         Do While comma
            NumItems = NumItems + 1
            comma = InStr(comma + 1, sites$, ",")
         Loop
   
         ReDim sitenos%(NumItems), siteabb$(NumItems), sitepth$(NumItems)
        
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         
         For count = 1 To NumItems
            sitenos%(count) = Val(sitepth$(count))
         Next
         sites$ = siteinfo$("dispdataDRVs", "")
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         sites$ = siteinfo$("hospabs", "")
         deflines sites$, siteabb$(), ",(*)", 1, NumItems
         For count = 1 To NumItems  ' example  G:\DISPDATA.003
            sitepth$(count) = sitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(sitenos%(count))), 3)
         Next
      Else
          ReDim sitenos%(0), siteabb$(0), sitepth$(0)
      End If
      
      sitenos%(0) = SiteNumber
      siteabb$(0) = hospabbr$
      sitepth$(0) = dispdata$
   End If
   
End Sub
Sub SetDispdata(site%)
' 6Jan95 CKJ Written. If site is in SITEINFO.INI then add drive letter
'            else assume same server
'            Site = 0  set dispdata to own sitenumber
'            Site = -1 returns number of sites (0-n)
'            Site > 0  set dispdata to specified site
'sitenos() sitepth() and dispdata$ are Named Common Shared
'22Apr07 TH Moved here from orderlibs to allow ref from prod stock editor

Dim count%
Dim strParams As String

   ReadSites
   Select Case site
      Case -1     ' how many sites?
         site = UBound(sitenos)
      Case 0      ' set to own site
         dispdata$ = sitepth$(0)
         'reset gDispSite
         strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
         gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
         
      Case Else   ' set to specified site
         For count = 0 To UBound(sitenos)
            If sitenos%(count) = site% Then
                  dispdata$ = sitepth$(count)
                  strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, site%)
                  gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
                  Exit For
               End If
         Next
         If count > UBound(sitenos) Then
            popmessagecr "WARNING", "Site " + Str$(site) + " missing from SITEINFO.INI"
            Close
            ''End
         End If
   End Select

End Sub
Function GetLabelRequestID() As Long
'06Jun08 TH Stubbage
GetLabelRequestID = 0

End Function
Function OCXheap(strVal As String, strDefault As String) As String
   OCXheap = strDefault
End Function

Sub StockOutput(d As DrugParameters, ByVal blnCreate As Boolean)
'20Mar09 TH Written for UHB SAGE Interface solution (F0032689)

Dim strRTFFile As String
Dim strFilename As String
Dim strPointerFilename As String
Dim strFilePrefix As String
Dim strOutfile As String
Dim lngPointer As Long
Dim lclsup As supplierstruct
Dim lngFound As Long
Dim strMsg As String
Dim strMethodTypes As String '18Mar09 TH
Dim strFilesuffix As String

   
      
   FillHeapDrugInfo gPRNheapID, d, 0
   
   getsupplier d.supcode, 0, lngFound, lclsup
   
   'Put the supplier information on the heap
   If lngFound Then FillHeapSupplierInfo gPRNheapID, lclsup, 0

   'Output the file
   strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "StockInterface", "", "RTFFile", 0)
   'strRTFFile = TxtD(dispdata$ & "\GenInt.INI", "StockInterface", strRTFFile, "RTFFile" & Ordlog.kind, 0) '03Mar09 TH Added
   If strRTFFile <> "" Then
      strRTFFile = dispdata & "\" & strRTFFile
      If fileexists(strRTFFile) Then
         strFilename = TxtD(dispdata$ & "\GenInt.INI", "StockInterface", "", "ExportFilePath", 0)
         If strFilename <> "" Then
            'strFile = strFilename
            If DirExists(strFilename) Then
                  Heap 10, gPRNheapID, "iUpdateflag", Iff(blnCreate, "Create", "Update"), 0
                  
                  'Now get a pointer to ensure unique file
                  strPointerFilename = TxtD(dispdata$ & "\GenInt.INI", "StockInterface", dispdata$ & "\StockInt.dat", "InterfacePointerFile", 0)
                  GetPointerSQL strPointerFilename, lngPointer, True
                  Heap 10, gPRNheapID, "OutputRefNoPad", Format$(lngPointer), 0
                  strFilePrefix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "StockInterface", "O", "FilePrefix", 0))
                  'strFilename = strFilename & "\" & strFilePrefix & Left$("0000000000", 10 - (Len(Format$(lngPointer)))) & Format$(lngPointer)
                  strFilename = strFilename & "\" & strFilePrefix & Format$(lngPointer, "0000000000")
                  
                  strFilesuffix = Trim$(TxtD(dispdata$ & "\GenInt.INI", "StockInterface", "", "Filesuffix", 0))
                  
                  strFilename = strFilename & strFilesuffix
                  
                  'Parse the file
                  parseRTF strRTFFile, strOutfile
                  strFilename = strFilename & TxtD(dispdata$ & "\GenInt.INI", "StockInterface", ".xml", "OutputFileExtension", 0)
                  On Error GoTo StockOutput_Err
                  FileCopy strOutfile, strFilename
                     
                  'remove the file afterwards
                  On Error Resume Next
                  If fileexists(strOutfile) Then Kill strOutfile
                  On Error GoTo 0
               Else
                  popmessagecr "", "Generic Interface Incorrectly configured - Export File Path Not Found"
               End If
         Else
            popmessagecr "", "Generic Interface Incorrectly configured - Export File Path required"
         End If
      Else
         popmessagecr "", "Generic Interface Incorrectly configured - Export File Not Found"
      End If
   Else
      popmessagecr "", "Generic Interface Incorrectly configured - Export File Required"
   End If
  
StockOutput_Exit:
   Exit Sub

StockOutput_Err:
   strMsg = "An error has occurred in procedure : StockOutput" & crlf & crlf
   strMsg = strMsg & "Error No. : " & Format$(Err) & crlf
   strMsg = strMsg & Error$
   popmessagecr ".", strMsg
   WriteLog dispdata$ & "\StockOutput.log", SiteNumber, UserID$, strMsg
   Resume StockOutput_Exit

End Sub

Private Sub AddPBSMappings()
'23Oct08 AK For creating new DrugIDLinkPBSProduct (F0033581)
'15Nov11 TH Ported from 9.9 whilst working on PCT

Dim strResult As String
Dim strSearch As String
Dim strParams As String
Dim rs As ADODB.Recordset

   On Error GoTo ErrorHandler
   k.escd = False '17Nov08 TH Added (tidying)
   'frmoptionset -1, "Choose Search Criterea"
   frmoptionset -1, "Choose Search Criteria"  '15Dec11 TH (TFS 21227)
   frmoptionset 1, "Search by PBS Code"
   frmoptionset 1, "Search by Description"
   frmoptionshow "1", strResult
   frmoptionset 0, ""
   If Val(strResult) = 0 Then k.escd = True
   If Not k.escd Then
      If Val(strResult) = 1 Then
         k.Max = 5
         k.min = 1
         InputWin "Add PBS Mappings", "Enter PBS code", strSearch, k
         If Not k.escd Then
            strParams = gTransport.CreateInputParameterXML("PBSCode", trnDataTypeVarChar, 5, Trim(strSearch))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPBSProductByPBSCode", strParams)
            If Not rs.EOF Then
               LstBoxFrm.LstBox.Clear
               LstBoxFrm.Caption = "Select PBS Product"
               LstBoxFrm.lblHead.Caption = _
                  "PBS Code" & TB & _
                  "ROP" & TB & _
                  "Description (Trade Name) - Form and Strength"
               rs.MoveFirst
               Do While Not rs.EOF
                  LstBoxFrm.LstBox.AddItem _
                     GetField(rs!PBSCode) & TB & _
                     GetField(rs!ROP) & TB & _
                     GetField(rs!DrugName) & " (" & _
                     GetField(rs!BrandName) & ") - " & _
                     GetField(rs!FormAndStrength)
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PBSMasterProductID)
                  rs.MoveNext
               Loop
            End If
            rs.Close
         End If
      ElseIf Val(strResult) = 2 Then
         k.min = 1
         k.Max = 80
         InputWin "View PBS Mappings", "Enter description", strSearch, k
         If Not k.escd Then
            strParams = gTransport.CreateInputParameterXML("DrugName", trnDataTypeVarChar, 5, Trim(strSearch))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPBSProductByDrugName", strParams)
            If Not rs.EOF Then
               LstBoxFrm.LstBox.Clear
               LstBoxFrm.Caption = "Select PBS Product"
               LstBoxFrm.lblHead.Caption = _
                  "PBS Code" & TB & _
                  "ROP" & TB & _
                  "Description (Trade Name) - Form and Strength"
               rs.MoveFirst
               Do While Not rs.EOF
                  LstBoxFrm.LstBox.AddItem _
                     GetField(rs!PBSCode) & TB & _
                     GetField(rs!ROP) & TB & _
                     GetField(rs!DrugName) & " (" & _
                     GetField(rs!BrandName) & ") - " & _
                     GetField(rs!FormAndStrength)
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PBSMasterProductID)
                  rs.MoveNext
               Loop
            End If
            rs.Close
         End If
      End If
      If Not k.escd Then '17Nov08 TH Added (tidying)
         LstBoxShow
         If LstBoxFrm.Tag <> "" Then
            strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID) _
                        & gTransport.CreateInputParameterXML("PBSMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pDrugIDLinkPBSProductByDrugIDAndPBSMasterProductID", strParams)
            If rs.EOF = False Then
               popmessagecr "!Duplicate Found", "This link has already been defined"
            Else
               strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID) _
                           & gTransport.CreateInputParameterXML("PBSMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) _
                           & gTransport.CreateInputParameterXML("Local", trnDataTypeBit, 1, 1)
               If gTransport.ExecuteInsertLinkSP(g_SessionID, "DrugIDLinkPBSProduct", strParams) <> 0 Then
                  popmessagecr "!Error", "Errors were encountered creating this link"
               End If
            End If
         End If
      End If         '17Nov08 TH Added (tidying)
   End If
   
Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
End Sub

Private Sub DeletePBSMappings()
'23oct08 AK For deleing mappings from DrugIDLinkPBSProduct (F0033581)
'15Nov11 TH Ported from 9.9 whilst working on PCT

Dim strParams As String
Dim rs As ADODB.Recordset
Dim intEsc As Integer
Dim strAnswer As String
   
   On Error GoTo ErrorHandler
   LstBoxFrm.LstBox.Clear
   strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pDrugIDLinkPBSProductLocalByDrugID", strParams)
   If Not rs.EOF Then
      LstBoxFrm.Caption = "Select PBS Product"
      LstBoxFrm.lblHead.Caption = _
         "PBS Code" & TB & _
         "ROP" & TB & _
         "Description (Trade Name) - Form and Strength"
      rs.MoveFirst
      Do While Not rs.EOF
         LstBoxFrm.LstBox.AddItem _
            GetField(rs!PBSCode) & TB & _
            GetField(rs!ROP) & TB & _
            GetField(rs!DrugName) & " (" & _
            GetField(rs!BrandName) & ") - " & _
            GetField(rs!FormAndStrength)
         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PBSMasterProductID)
         rs.MoveNext
      Loop
      rs.Close
      LstBoxShow
      If LstBoxFrm.Tag <> "" Then
         'popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.Description) & " and " & Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1) & "?", 3, strAnswer, intEsc   XN 4Jun15 98073 New local stores description
                 popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.LabelDescription) & " and " & Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1) & "?", 3, strAnswer, intEsc
         If strAnswer = "Y" Then
            strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID) _
                        & gTransport.CreateInputParameterXML("PBSMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) _
                        & gTransport.CreateInputParameterXML("Local", trnDataTypeBit, 1, 1)
            gTransport.ExecuteDeleteLinkSP g_SessionID, "DrugIDLinkPBSProduct", strParams
         End If
      End If
   Else
      'popmessagecr "#No Mappings Found", "There are no local PBS Mappings for " & Trim(d.Description) XN 4Jun15 98073 New local stores description
          popmessagecr "#No Mappings Found", "There are no local PBS Mappings for " & Trim(d.LabelDescription)
   End If

Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
End Sub

Private Sub AddPCTMappings()
'15Nov11 TH Written based on PBS Mapper. Simple picker and selector to add a PCT ingredient to a Pharmacy product
'24Jan12 TH Added PUOM

Dim strResult As String
Dim strSearch As String
Dim strParams As String
Dim rs As ADODB.Recordset

   On Error GoTo ErrorHandler
   k.escd = False '17Nov08 TH Added (tidying)
   'frmoptionset -1, "Choose Search Criterea"
   frmoptionset -1, "Choose Search Criteria"  '06Jan12 TH
   frmoptionset 1, "Search by Pharmacode"
   frmoptionset 1, "Search by Description"
   frmoptionshow "1", strResult
   frmoptionset 0, ""
   If Val(strResult) = 0 Then k.escd = True
   If Not k.escd Then
      If Val(strResult) = 1 Then
         k.Max = 10 '?
         k.min = 1
         k.decimals = False
         k.nums = True
         InputWin "Add PCT Mappings", "Enter Pharmacode", strSearch, k
         If Not k.escd Then
            strParams = gTransport.CreateInputParameterXML("Pharmacode", trnDataTypeint, 4, Val(strSearch))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductByPharmacode", strParams)
            If Not rs.EOF Then
               LstBoxFrm.LstBox.Clear
               LstBoxFrm.Caption = "Select PCT Product"
               LstBoxFrm.lblHead.Caption = _
                  "Pharmacode" & TB & _
                  "PUOM   " & TB & _
                  "Chemical" & Space(20) & TB & _
                  "Formulation" & Space(20) & TB & _
                  "Brand" & Space(50) & TB & TB & TB
               rs.MoveFirst
               Do While Not rs.EOF
                  LstBoxFrm.LstBox.AddItem _
                     GetField(rs!PharmaCode) & TB & _
                     GetField(rs!Units) & TB & _
                     GetField(rs!ChemicalName) & TB & _
                     GetField(rs!FormulationName) & TB & _
                     GetField(rs!BrandName) & TB & TB
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PCTMasterProductID)
                  rs.MoveNext
               Loop
            Else
               popmessagecr "PCT Mapping", "No PCT record matches for " & Trim$(strSearch)
               k.escd = True
            End If
            rs.Close
         End If
      ElseIf Val(strResult) = 2 Then
         k.min = 1
         k.Max = 80
         InputWin "View PCT Mappings", "Enter chemical description", strSearch, k
         If Not k.escd Then
            strParams = gTransport.CreateInputParameterXML("ChemicalName", trnDataTypeVarChar, 5, Trim(strSearch))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductByChemicalName", strParams)
            If Not rs.EOF Then
               LstBoxFrm.LstBox.Clear
               LstBoxFrm.Caption = "Select PCT Product"
               LstBoxFrm.lblHead.Caption = _
                  "Pharmacode" & TB & _
                  "PUOM   " & TB & _
                  "Chemical" & Space(20) & TB & _
                  "Formulation" & Space(20) & TB & _
                  "Brand" & Space(50) & TB & TB & TB
               rs.MoveFirst
               Do While Not rs.EOF
                  LstBoxFrm.LstBox.AddItem _
                     GetField(rs!PharmaCode) & TB & _
                     GetField(rs!Units) & TB & _
                     GetField(rs!ChemicalName) & TB & _
                     GetField(rs!FormulationName) & TB & _
                     GetField(rs!BrandName) & TB
                  LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PCTMasterProductID)
                  rs.MoveNext
               Loop
            Else
               popmessagecr "PCT Mapping", "No PCT record matches for " & Trim$(strSearch)
               k.escd = True
            End If
            rs.Close
         End If
      End If
      If Not k.escd Then '17Nov08 TH Added (tidying)
         LstBoxShow
         If LstBoxFrm.Tag <> "" Then
            strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                        & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
            Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockIDAndPCTMasterProductID", strParams)
            If rs.EOF = False Then
               popmessagecr "!Duplicate Found", "This link has already been defined"
            Else
               'Check for existing primary Ingredient
               'If there is a primary link then we will notify the user that this will be recorded as AboutBox secondary ingredient
               strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID)
                       
               Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockID", strParams)
               If rs.EOF = False Then
                  popmessagecr "!Primary Match Found", "There is already a primary ingredient mapped to this product." _
                  & crlf & crlf & "This mapping will be designated as a secondary ingredient." _
                  & crlf & "If you wish to change the primary ingredient then you use the Switch primary Ingredient option from the product editor menu"
                  strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                              & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) _
                              & gTransport.CreateInputParameterXML("Primary", trnDataTypeBit, 1, 0)
               Else
                  'Otherwise we record normally
                  strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                              & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)) _
                              & gTransport.CreateInputParameterXML("Primary", trnDataTypeBit, 1, 1)
               End If
                           
               If gTransport.ExecuteInsertLinkSP(g_SessionID, "PCTProductLinkProductStock", strParams) <> 0 Then
                  popmessagecr "!Error", "Errors were encountered creating this link"
               End If
            End If
         End If
      End If         '17Nov08 TH Added (tidying)
   End If
   
Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
End Sub

Private Sub DeletePCTMappings()
'16Nov11 TH New editor to allow a user to delete PCT mappings

Dim strParams As String
Dim rs As ADODB.Recordset
Dim intEsc As Integer
Dim strAnswer As String
Dim strDesc As String
Dim lngResult As Long
   
   On Error GoTo ErrorHandler
   LstBoxFrm.LstBox.Clear
   strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockIDSECONDARY", strParams)
   If Not rs.EOF Then
      popmessagecr "PCT Linking", "This item has linked secondary ingredients. These must be deleted before the primary ingredient." _
               & crlf & "If you wish to change the primary ingredient please use the Switch Primary Ingredient menu option"
      
      LstBoxFrm.Caption = "Select Linked PCT Secondary Ingredient"
      LstBoxFrm.lblHead.Caption = _
                  "Pharmacode" & TB & _
                  "PUOM   " & TB & _
                  "Chemical" & Space(20) & TB & _
                  "Formulation" & Space(20) & TB & _
                  "Brand" & Space(50) & TB & TB & TB
      rs.MoveFirst
      Do While Not rs.EOF
         LstBoxFrm.LstBox.AddItem _
            GetField(rs!PharmaCode) & TB & _
            GetField(rs!Units) & TB & _
            GetField(rs!ChemicalName) & TB & _
            GetField(rs!FormulationName) & TB & _
            GetField(rs!BrandName) & TB & TB
         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PCTMasterProductID)
         rs.MoveNext
      Loop
      rs.Close
      LstBoxShow
      If LstBoxFrm.Tag <> "" Then
         strDesc = Trim$(Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1))
         replace strDesc, TB, " ", 0
         replace strDesc, "  ", " ", 0
         'popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.Description) & " and " & strDesc & " ?", 3, strAnswer, intEsc  XN 4Jun15 98073 New local stores description
                 popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.LabelDescription) & " and " & strDesc & " ?", 3, strAnswer, intEsc
         If strAnswer = "Y" Then
            strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                        & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
            lngResult = gTransport.ExecuteDeleteLinkSP(g_SessionID, "PCTProductLinkProductStock", strParams)
         End If
      End If
   Else
      'No Secondary ingredients so allow the deletion of the primary ingredient
      rs.Close
      Set rs = Nothing
      strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID)
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockIDPRIMARY", strParams)
      If Not rs.EOF Then
         LstBoxFrm.Caption = "Select Linked PCT Primary Ingredient"
         LstBoxFrm.lblHead.Caption = _
                     "Pharmacode" & TB & _
                     "PUOM   " & TB & _
                     "Chemical" & Space(20) & TB & _
                     "Formulation" & Space(20) & TB & _
                     "Brand" & Space(50) & TB & TB & TB
         rs.MoveFirst
         Do While Not rs.EOF
            LstBoxFrm.LstBox.AddItem _
               GetField(rs!PharmaCode) & TB & _
               GetField(rs!Units) & TB & _
               GetField(rs!ChemicalName) & TB & _
               GetField(rs!FormulationName) & TB & _
               GetField(rs!BrandName) & TB & TB
            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PCTMasterProductID)
            rs.MoveNext
         Loop
         rs.Close
         LstBoxShow
         If LstBoxFrm.Tag <> "" Then
            strDesc = Trim$(Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1))
            replace strDesc, TB, " ", 0
            replace strDesc, "  ", " ", 0
            strAnswer = "N"
            'popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.Description) & " and " & strDesc & " ?", 515, strAnswer, intEsc  XN 4Jun15 98073 New local stores description
                        popmsg "Confirm Deletion", "Are you sure you wish to delete the link between " & Trim$(d.LabelDescription) & " and " & strDesc & " ?", 515, strAnswer, intEsc
            If strAnswer = "Y" Then
               strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                           & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
               lngResult = gTransport.ExecuteDeleteLinkSP(g_SessionID, "PCTProductLinkProductStock", strParams)
            Else
               popmessagecr "", "No links have been deleted"
            End If
         End If
     Else
        'popmessagecr "#No Mappings Found", "There are no PCT Mappings for " & Trim(d.Description)  XN 4Jun15 98073 New local stores description
                popmessagecr "#No Mappings Found", "There are no PCT Mappings for " & Trim(d.LabelDescription)
        rs.Close
       Set rs = Nothing
     End If
     
      
      'popmessagecr "#No Mappings Found", "There are no local PBS Mappings for " & Trim(d.Description)
   End If

Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
End Sub

Public Sub SetPCTPrimaryIngredient()
'16Nov11 TH Editor to allow user to switch a secondary ingredient to the primary ingredient for PCT linked to this product

Dim strDesc As String
Dim rs As ADODB.Recordset
Dim strParams As String
Dim strAns As String
Dim strAnswer As String
Dim lngResult As Long
Dim strProductDesc As String

   On Error GoTo ErrorHandler
   LstBoxFrm.LstBox.Clear
   strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockIDSECONDARY", strParams)
   If Not rs.EOF Then
      LstBoxFrm.Caption = "Select Linked PCT Secondary Ingredient to become new Primary Ingredient"
      LstBoxFrm.lblHead.Caption = _
                  "Pharmacode" & TB & _
                  "PUOM   " & TB & _
                  "Chemical" & Space(20) & TB & _
                  "Formulation" & Space(20) & TB & _
                  "Brand" & Space(50) & TB & TB & TB
      rs.MoveFirst
      Do While Not rs.EOF
         LstBoxFrm.LstBox.AddItem _
            GetField(rs!PharmaCode) & TB & _
            GetField(rs!Units) & TB & _
            GetField(rs!ChemicalName) & TB & _
            GetField(rs!FormulationName) & TB & _
            GetField(rs!BrandName) & TB & TB
         LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = GetField(rs!PCTMasterProductID)
         rs.MoveNext
      Loop
      rs.Close
      Set rs = Nothing
      LstBoxShow
      If LstBoxFrm.Tag <> "" Then
         'strDesc = Trim$(Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1))
         strDesc = Trim$(Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB), LstBoxFrm.Tag, TB) + 1))  'TFS19746
         replace strDesc, TB, " ", 0
         replace strDesc, "  ", " ", 0
         strProductDesc = Trim$(d.LabelDescription)     'strProductDesc = Trim$(d.Description)  XN 4Jun15 98073 New local stores description
         plingparse strProductDesc, "!"
         popmsg "Confirm Switch", "Are you sure you wish to make " & strDesc & " the primary PCT ingredient for " & strProductDesc & " ?", 3, strAnswer, 0
         If strAnswer = "Y" Then
            strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
                        & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex))
            lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPCTProductLinkProductStockSwitchPrimary", strParams)
         End If
      End If
   Else
      rs.Close
      Set rs = Nothing
      popmessagecr "", "There are no secondary ingredients to switch to the primary ingredient for this product"
      'k.escd = True 'Not really interested !
   End If
   
Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
      
End Sub

Public Sub ViewPCTMappings()
'16Nov11 TH Simple view for all PCT ingredients linked to this product
'24Jan12 TH Added PUOM

Dim strDesc As String
Dim rs As ADODB.Recordset
Dim strParams As String
Dim strAns As String
Dim strAnswer As String
Dim lngResult As Long
Dim strProductDesc As String

   On Error GoTo ErrorHandler
   LstBoxFrm.LstBox.Clear
   strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPCTProductLinkProductStockByProductStockID", strParams)
   If Not rs.EOF Then
      LstBoxFrm.Caption = "These PCT ingredients are currently linked to this product"
      LstBoxFrm.lblHead.Caption = _
                  "Ingredient" & TB & _
                  "Pharmacode" & TB & _
                  "PUOM   " & TB & _
                  "Chemical" & Space(20) & TB & _
                  "Formulation" & Space(20) & TB & _
                  "Brand" & Space(50) & TB & TB & TB
      rs.MoveFirst
      Do While Not rs.EOF
         LstBoxFrm.LstBox.AddItem _
            Iff(GetField(rs!Primary), "Primary", "Secondary") & TB & _
            GetField(rs!PharmaCode) & TB & _
            GetField(rs!Units) & TB & _
            GetField(rs!ChemicalName) & TB & _
            GetField(rs!FormulationName) & TB & _
            GetField(rs!BrandName) & TB & TB
         'LstBoxFrm.Lstbox.ItemData(LstBoxFrm.Lstbox.NewIndex) = GetField(rs!PCTMasterProductID)
         rs.MoveNext
      Loop
      rs.Close
      Set rs = Nothing
      LstBoxShow
'      If LstBoxFrm.Tag <> "" Then
'         strDesc = Trim$(Mid(LstBoxFrm.Tag, InStr(InStr(LstBoxFrm.Tag, TB) + 1, LstBoxFrm.Tag, TB) + 1))
'         replace strDesc, TB, " ", 0
'         replace strDesc, "  ", " ", 0
'         strProductDesc = Trim$(d.Description)
'         plingparse strProductDesc, "!"
'         popmsg "Confirm Switch", "Are you sure you wish to make " & strDesc & " the primary PCT ingredient for " & strProductDesc & " ?", 3, strAnswer, 0
'         If strAnswer = "Y" Then
'            strParams = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) _
'                        & gTransport.CreateInputParameterXML("PCTMasterProductID", trnDataTypeint, 4, LstBoxFrm.Lstbox.ItemData(LstBoxFrm.Lstbox.ListIndex))
'            lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPCTProductLinkProductStockSwitchPrimary", strParams)
'         End If
'      End If
   Else
      rs.Close
      Set rs = Nothing
      popmessagecr "", "There are no PCT ingredients linked to this product"
      'k.escd = True 'Not really interested !
   End If
   
Cleanup:
   On Error GoTo 0
   Unload LstBoxFrm
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then rs.Close
      Set rs = Nothing
   End If
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup
      
End Sub

Sub StoreUCHwnd(ByVal Hwnd As Long)
'12Jul12 CKJ added for Mechdisp
   
   m_UCHWnd = Hwnd

End Sub

Function GetNewParentHWnd() As Long
'12Jul12 CKJ added for Mechdisp

   GetNewParentHWnd = m_UCHWnd

End Function

Function SendRobotProductData(dlocal As DrugParameters) As Boolean
'12Jul12 CKJ Written, based on V8.9 Product Review/Enquiry/Label in Stock Maint.
'            Rowa needs description checking & pruning, Apostore doesn't need description sending

Dim sDesc As String
Dim sDescWas As String
Dim success As Boolean
Dim sMsg As String
Dim sMachine As String
Dim iMaxLen As Integer
Dim iLastLen As Integer
Dim sAbbrev As String
Dim iLine As Integer
Dim iLines As Integer
Dim sLine As String
Dim sSep As String
Dim iPos As Integer
Dim iPos2 As Integer
Dim sWas As String
Dim sNow As String

   success = False
   If MechDispSendProductDataSupported(dlocal, sMachine) Then
      If LCase$(sMachine) = "rowa" Then
         'sDesc = trimz$(d.storesdescription)
         'If sDesc = "" Then sDesc = trimz$(d.Description)  XN 4Jun15 98073 New local stores description
                 sDesc = trimz$(d.DrugDescription)
         plingparse sDesc, "!"
         sDescWas = sDesc                    'keep copy for comparison
         
         replace sDesc, " & ", " and ", 0    'acceptable alternative for &
         replace sDesc, "|", " ", 0          'parse HL7 reserved chars
         replace sDesc, "^", " ", 0
         replace sDesc, "~", " ", 0
         replace sDesc, "\", " ", 0
         replace sDesc, "&", "+", 0
         replace sDesc, "  ", " ", 0         'remove double spaces
         sDesc = trimz$(sDesc)               'trim leading & trailing spaces
               
         iMaxLen = 40                        'May make configurable if ever needed for a different interface
         If Len(sDesc) > iMaxLen Or sDesc <> sDescWas Then              'Show amended description, edit is essential if over 40 chars
            sAbbrev = TxtD(dispdata$ & "\mechdisp.ini", "common", "", "AbbreviationRules", 0) '1024 max not long enough; expanded to 8000
            replace sAbbrev, vbCrLf, vbCr, 0
            replace sAbbrev, vbLf, vbCr, 0
            ReDim abbrev(4000) As String                                '8000 char max, each line at least 1 char & <cr>
            deflines sAbbrev, abbrev(), vbCr, 1, iLines                 'ignore empty lines
            For iLine = 1 To iLines
               sLine = abbrev(iLine)
               If Len(sLine) >= 4 Then                                  'minimum is change 1 char to nothing eg 'a''
                  sSep = Left$(sLine, 1)
                  If sSep <> " " And sSep <> TB Then                    'first character is not white space
                     sLine = Mid$(sLine, 2)                             'chop off first separator
                     iPos = InStr(1, sLine, sSep, vbBinaryCompare)      'get middle separator
                     If iPos > 1 Then                                   'at least one char to search on
                        sWas = Left$(sLine, iPos - 1)
                        sLine = Mid$(sLine, iPos + 1)
                        iPos2 = InStr(1, sLine, sSep, vbBinaryCompare)  'get next separator (should be last one)
                        If iPos2 Then
                           sNow = Left$(sLine, iPos2 - 1)               'can be blank
                           If InStr(1, sNow, sWas, 1) = 0 Then          'avoid infinite recursion
                              replace sDesc, sWas, sNow, -iMaxLen
                              sDesc = Trim$(sDesc)
                           End If
                           If Len(sDesc) <= iMaxLen Then Exit For
                        End If
                     End If
                  End If
               End If
            Next
            
            Do
               Editor.lblTitle.Caption = sDescWas & vbCrLf & "Check the product description, ensuring it fits in a maximum of " & Format$(iMaxLen) & " characters"
               Editor.cmdBtn(1).Visible = False
               Editor.cmdBtn(0).Visible = False
               Editor.cmdExit.Caption = "&OK"
               'Editor.cmdExit.default = True  can't do this; sets read-only
               Editor.Txt1.Text = sDesc & vbCrLf & String$(40, "~") & "|"  'guide added below will be parsed out as it uses HL7 chars
               Editor.Txt1.Tag = ""             'don't put copy of sDesc in the tag, otherwise return with no edits is treated like 'Esc'
               'Editor.lblCode.Caption          'box in lower left corner - may be set below for 2nd pass
               Editor.Caption = "Product Description"
               Editor.cmdExit.default = False   'view & edit
               Editor.Tag = "L"                 'Label' editing sets ruler & fixed font
               gTimedOut = False
               CentreForm Editor
               Editor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
               sDesc = Editor.Txt1.Text
               k.escd = (Editor.cmdExit.Tag <> "-1")
               Unload Editor
               
               If Not k.escd Then
                  plingparse sDesc, "!"
                  replace sDesc, vbCr, "", 0    'turn any CRLF into one space
                  replace sDesc, vbLf, " ", 0
                  replace sDesc, "|", " ", 0    'parse HL7 reserved chars
                  replace sDesc, "^", " ", 0
                  replace sDesc, "~", " ", 0
                  replace sDesc, "\", " ", 0
                  replace sDesc, "&", "+", 0
                  replace sDesc, "  ", " ", 0   'remove double spaces
                  sDesc = trimz$(sDesc)         'trim leading & trailing spaces
                  If Len(sDesc) > iMaxLen Then Editor.lblCode.Caption = "  Description was " & Format$(Len(sDesc) - iMaxLen) & " character" & plural(Len(sDesc) - iMaxLen) & " too long  "
               End If
            Loop While Len(sDesc) > iMaxLen And Not k.escd
         End If
      End If
   
      If Not k.escd Then
         success = MechDispSendProductData(dlocal, sDesc, "", sMsg)
         If Len(sMsg) Then popmessagecr "#", sMsg
      End If
   Else
      popmessagecr "#", "Option not available for machine " & sMachine
   End If
   
End Function

Function PrintShelfLabel(dlocal As DrugParameters) As Integer
'17Jul12 CKJ Ported from V8.9
'            Given a drug, print a label using shelflbl.rtf if this exists
'            Returns success T/F

Dim success As Integer
   
   If Not fileexists(dispdata$ & "\ShelfLbl.rtf") Then
      popmessagecr "!", "Shelf label layout file has not been created" & cr & "Please set this up using the label editor desktop"
   Else
      FillHeapDrugInfo gPRNheapID, dlocal, success
      If success Then
         ParseThenPrint "ShelfLbl", dispdata$ & "\shelflbl.rtf", 1, success, False, False '08Jan17 TH added param
      End If
      PrintShelfLabel = success
   End If

End Function

Sub ChoosePIL(Code$, desc$)
'11Apr97 CKJ Procedure written - crude but simple
'23Sep99 CFY Re-written - Simple but effective
'12Jun02 CKJ Corrected - caused illegal function call on escape from list
'14Jan13 TH Ported from Version 8
Dim SelectedFile$

   EditFiles dispdata$ & "\pil", "pil", "Patient Information Leaflets", 3, SelectedFile$
   'code$ = Left$(SelectedFile$, Len(SelectedFile$) - 4)             '12Jun02 CKJ
   If Len(SelectedFile$) > 4 Then                                    '   "
         Code$ = Left$(SelectedFile$, Len(SelectedFile$) - 4)        '   "
      End If                                                         '   "
   'desc$ = "Shift-F1 for list"                                      '   "



End Sub

Sub EditFiles(Filepath$, fileext$, Caption$, Mode%, SelectedFile$)
'23Sep99 CFY Written
'05Jan00 AW Changed to check for "<New>" rather than "New".
'12Jan00 SF added call to FlushIniCache: so descriptions held in ini files can be changed and displayed
'           without having to exit the program

'Will create a ini file to store a human readable description of each file
'This is then presented as a list to the user in order to select the file to edit.
'
' Given :   Filepath$:     a file path in which rtf files are located
'           FileExt$:      a common file extension
'           Caption$:      Caption on title bar
'           Mode:          1 = Edit, 2 = View, 3 = Select
'Pass Back: SelectedFile$: Filename selected
'
'26Nov99 AW  added extra menu item to allow new files to be created
'12Jun02 CKJ Corrected faults in the 'New' routine. Overhauled & tidied
'14Jan13 TH Ported - convert PILdesc.ini

Dim NumEntries%, i%, Numoflines%, Choice%, Selected%
Dim iniFile$, FILE$, FileFound$, Text$, ans$, msg$
Dim blnValid As Integer          '12Jun02 CKJ
Dim strExtn As String            '   "

   FlushIniCache     '12Jan00 SF added to refresh any descriptions changed ini files without having to exit the program
   ReDim lines$(5)
   ReDim Action%(4)
   strExtn = UCase$(Trim$(fileext$))                                                      '12Jun02 CKJ
   iniFile$ = Filepath$ & "\" & strExtn & "desc.ini"                                      'eg. dispdata.002\pil\pildesc.ini
   FILE$ = Filepath$ & "\*." & strExtn                                                    'eg. dispdata.002\pil\*.pil

   '14Jan13 TH Now read totals and use this as a marker on whether to "reget" the files
   NumEntries = Val(TxtD(iniFile$, "", "0", "NumEntries", 0))
   
   'Check description file exists, If not then create it.
   'If Not fileexists(inifile$) Then
   If NumEntries < 1 Then  '14Jan13 TH Replaced above
      FileFound$ = Dir$(FILE$)
      Do While FileFound$ <> ""
         NumEntries = NumEntries + 1
         Text$ = FileFound$ & "|" & "<No Description>"
         WritePrivateIniFile "", Format$(NumEntries), Text$, iniFile$, 0               'Write entry to ini file
         FileFound$ = Dir$
      Loop
      WritePrivateIniFile "", "NumEntries", Format$(NumEntries), iniFile$, 0           'Write total to ini file
   End If

   'Display list of available files to user for editing..
   NumEntries = Val(TxtD(iniFile$, "", "0", "NumEntries", 0))
   ReDim FileLookup$(NumEntries)
   ReDim DescLookup$(NumEntries)

   LstBoxFrm.Caption = Caption$
   LstBoxFrm.lblTitle = crlf & "Select file" & crlf & "Press Shift-F1 or Right Click for menu" & crlf
   LstBoxFrm.lblHead = "     File      " & TB & " Description"

   For i = 1 To NumEntries
      Text$ = TxtD(iniFile$, "", "", Format$(i), 0)
      deflines Text$, lines$(), "|", 1, Numoflines
      FileLookup$(i) = lines$(1)                                               'Store filename
      DescLookup$(i) = lines$(2)
      LstBoxFrm.LstBox.AddItem pad$(lines$(1), 15) & TB & lines$(2)            'Add to menu
   Next
   
   Do
      'Create appropriate popmenu dependant on mode
      popmenu 0, "", False, False
      Select Case Mode
         Case 1   'Full access for editing files
            'popmenu 2, "Edit" & cr & "Edit Description", False, False
            'popmenu 2, "Edit" & cr & "Edit Description" & cr & "New", False, False     '26Nov99 AW added extra menu item  '05Jan00 AW changed
            popmenu 2, "Edit" & cr & "Edit Description" & cr & "<New>", False, False                                       '         "
            Action(1) = 1    'Edit File
            Action(2) = 2    'Edit Description
            Action(3) = 5    'New File                                                 ' New File menu item
         Case 2   'View-only access
            popmenu 2, "View", False, False
            Action(1) = 3    'View
         Case 3   'View-only with ability to select a file and pass back to calling routine
            popmenu 2, "Select" & cr & "View", False, False
            Action(1) = 4    'Select
            Action(2) = 3    'View
         End Select
      
      LstBoxShow
      Selected = LstBoxFrm.LstBox.ListIndex + 1
      Choice = Val(PopMnu.Tag)

      If Selected <> 0 Then
            If Choice = 0 Then Choice = 1
            Select Case Action(Choice)
               Case 1      'Edit File
                  Hedit 11, Filepath$ & "\" & FileLookup$(Selected)

               Case 2      'Edit Description
                  ans$ = DescLookup$(Selected)
                  k.Max = 50
                  InputWin Caption$, crlf & "Enter new description for " & FileLookup$(Selected) & crlf, ans$, k
                  If Not k.escd Then
                        DescLookup$(Selected) = Trim$(ans$)
                        LstBoxFrm.LstBox.RemoveItem Selected - 1
                        LstBoxFrm.LstBox.AddItem FileLookup$(Selected) & TB & DescLookup$(Selected), Selected - 1
                        WritePrivateIniFile "", Format$(Selected), FileLookup$(Selected) & "|" & DescLookup$(Selected), iniFile$, 0
                     End If

               Case 3      'View File
                  Hedit 10, Filepath$ & "\" & FileLookup$(Selected)

               Case 4      'Select File
                  SelectedFile$ = FileLookup$(Selected)
                  Selected = 0

               Case 5      'New File                                                   '26Nov99 AW added
                  
                  ans$ = ""
                  msg$ = ""
                  blnValid = False
                  Do
                     k.min = 1
                     k.Max = 5
                     k.nums = True
                     k.decimals = False
                     InputWin Caption$, crlf & "Please enter name of the new file as 1 to 5 digits" & crlf & msg$, ans$, k
                     If Not k.escd Then
                           If Val(ans$) > 32767 Then
                                 msg$ = "Note: This must be 32767 or less"
                              ElseIf fileexists(Filepath & "\" & ans$ & "." & strExtn) Then
                                 msg$ = "Note: File " & ans$ & " already exists"
                              Else
                                 blnValid = True
                              End If
                        End If
                  Loop While Not blnValid And Not k.escd

                  If Not k.escd Then
                        NumEntries = NumEntries + 1
                        ReDim Preserve FileLookup$(NumEntries)
                        ReDim Preserve DescLookup$(NumEntries)
                        Selected = NumEntries
                        FileLookup$(Selected) = ans$ & "." & strExtn
                        
                        'enter optional description
                        DescLookup$(Selected) = "<No Description>"
                        ans$ = ""
                        k.Max = 50
                        InputWin Caption$, crlf & "Enter description for " & FileLookup$(Selected) & crlf, ans$, k
                        If Not k.escd Then DescLookup$(Selected) = Trim$(ans$)
                        
                        Text$ = FileLookup$(Selected) & "|" & DescLookup$(Selected)
                        WritePrivateIniFile "", "NumEntries", Format$(NumEntries), iniFile$, 0
                        WritePrivateIniFile "", Format$(NumEntries), Text$, iniFile$, 0
                        copy dispdata$ & "\Blank.rtf", Filepath$ & "\Blank.rtf"
                        Name Filepath$ & "\Blank.rtf" As Filepath$ & "\" & FileLookup$(Selected)
                        Hedit 11, Filepath$ & "\" & FileLookup$(Selected)
                        LstBoxFrm.LstBox.AddItem FileLookup$(Selected) & TB & DescLookup$(Selected)
                        LstBoxFrm.LstBox.Refresh
                     End If
               End Select
         End If

   Loop Until Selected = 0

   Unload LstBoxFrm
   popmenu 0, "", False, False

End Sub

