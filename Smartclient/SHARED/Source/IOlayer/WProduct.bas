Attribute VB_Name = "WProductIO"
' WProductIO
'------------
'07Oct04 CKJ Product access module, released for testing
'
'Locking not yet implemented

'------------------------------------------------
'V10 Consolidation

'03Sep08 TH  PutSiteProductDataNL: Added (F0027850) Added new (old)  dose range fields.
'03Sep08 TH  ProductLookup: Added new param to filter on route (F0031980)
'22oct08 AK  CastRecordsetToProduct/PutSiteProductDataNL: Added new _Locked fields (F0018781)
'23Apr09 TH  BlankWProduct: Added supplier profile blanking(F0031619). The ID here was being used as a flag
'            in supplier switching and because this wasnt being cleared this led to profiles not being saved after
'            switching sups in the same session. Also added ref no and suptrade name at same time to tidy up.
'20Aug09 PJC Declarations: Amended the LedCode length in Type DrugParameters (F0050136)
'            PutProductNL: Amended the ledcode parameter definition length changed from 7 to 20 (F0050136)
'07Apr10 AJK WProduct.BAS DrugParameters type: Added new fields for F0072782 & F0072542
'            WProduct.BAS PutProductNL: Added new fields for F0072782 & F0072542
'            WProduct.BAS CastRecordsetToProduct: Added new fields for F0072782 & F0072542
'            WProduct.BAS BlankWProduct: Added new fields for F0072782 & F0072542
'            WProduct.BAS PutSiteProductDataNL: Added new fields for F0072782 & F0072542
'14Apr10 AJK WProduct.BAS DrugParameters type: Added new fields for F0072782
'            WProduct.BAS PutProductNL: Added new fields for F0072782
'            WProduct.BAS CastRecordsetToProduct: Added new fields for F0072782
'            WProduct.BAS BlankWProduct: Added new fields for F0072782
'            WProduct.BAS PutSiteProductDataNL: Added new fields for F0072782
'20Apr10 AJK GetProductRSByDrugID Written F0077124. Returns all WProduct rows for a given NSVCode, regardless of Site
'20Apr10 AJK GetProductRSByNSV Written F0077124. Returns all WProduct rows for a given NSVCode, regardless of Site
'06May10 AJK ProductLookup: F0073627 Added otherroutes parameter
'27May10 AJK Declarations: F0061692 Changed d.EDILinkcode to string as it's a barcode that may have leading 0's
'03Aug10 XN  CastRecordsetToProduct: F0088717 InUse can't be S anymore so force to "Y"
'10Oct10 TH  Extend supplier reference to 36 chars (F0094388/RCN545)
'27Jan12 CKJ Added PNExclude flag to ProductStock
'10May12 XN  DrugParameters: Added CanUseSpoon lock field TFS33227
'            CastRecordsetToProduct: Loaded CanUseSpoon field from DB TFS33227
'            PutSiteProductDataNL: Added saving CanUseSpoon field to DB TFS33227
'31Jan13 TH  Added Eye Label Flag (TFS 39777) (TFS 55067)
'31Jan13 TH  CastRecordsetToProduct,PutProductNL: Added EyeLabel (TFS 39777) (TFS 55067)
'30Apr15 XN  Added DrugParameters.LabelDescriptionInpatient alternate label for in-patients (TFS 98073)
'05May15 XN  Added DrugParameters.LabelDescriptionOutpatient alternate label for out-patients (TFS 98073)
'20May15 XN  Added DrugParameters.LocalDescription (TFS 98073)
'26Jul16 XN  Added DrugParameters.EDIBarcode 126634
'			 CastRecordsetToProduct: Added reading EDIBarcode 126634
'            BlankWProduct: Clear EDIBarcode 126634

Option Explicit
DefInt A-Z

Private Const OBJNAME As String = PROJECT & "WProductIO."

'wProduct view
'=============
'   ProductID
'   SisCode
'   Code
'   BarCode
'   bnf
'   Description
'   labeldescription
'   tradename
'   PrintformV
'   storesdescription
'   storespack
'   convfact
'   dosesperissue
'   DosingUnits
'   mlsperpack
'   cyto
'   warcode
'   warcode2
'   inscode
'   dircode
'   ProductStockID
'   LocationID_Site
'   inuse
'   formulary
'   labelformat
'   extralabel
'   expiryminutes
'   minissue
'   maxissue
'   lastissued
'   issueWholePack
'   stocklvl
'   sisstock
'   livestockctrl
'   reorderlvl
'   reorderqty
'   ordercycle
'   cyclelength
'   outstanding
'   loccode
'   loccode2
'   anuse
'   usethisperiod
'   recalcatperiodend
'   datelastperiodend
'   usagedamping
'   safetyfactor
'   reorderpcksize
'   leadtime
'   supcode
'   altsupcode
'   contno
'   lastordered
'   stocktakestatus
'   laststocktakedate
'   laststocktaketime
'   batchtracking
'   cost
'   lossesgains
'   vatrate
'   sislistprice
'   contprice
'   lastreconcileprice
'   ledcode
'   pflag
'   message
'   UserMsg
'   PILnumber
'   PIL2
'   CreatedUser
'   createdterminal
'   createddate
'   createdtime
'   modifieduser
'   modifiedterminal
'   modifieddate
'   modifiedtime
'   local


'ORIGINAL from V8.x
'Type drugparameters
'   Code As String * 8
'   Description As String * 56
'   inuse As String * 1
'   deluserid As String * 3 '31May93
'   tradename As String * 30
'   cost As String * 9
'   contno As String * 10
'   supcode As String * 5
'   'altsupcode AS STRING * 35   '14Mar95 CKJ
'   altsupcode As String * 29
'   warcode2 As String * 6
'   ledcode As String * 7
'   SisCode As String * 7
'   BarCode As String * 13
'   cyto As String * 1
'   civas As String * 1
'   formulary As String * 1
'   bnf As String * 13        'was * 30 ASC 28Mar94
'
'   ReconVol As Single        '<---CIVA added ASC 28Mar94
'   ReconAbbr As String * 3
'   Diluent1Abbr As String * 3
'   Diluent2Abbr As String * 3
'   MaxmgPerml As Single      '<---TO HERE
'
'   warcode As String * 6
'   inscode As String * 6
'   dircode As String * 6
'   labelformat As String * 1  'was labelform ASC 28Mar94
'   expiryminutes As Long
'   sisstock As String * 1
'   ATC As String * 1             '23Dec93 CKJ
'   reorderpcksize As String * 5
'   PrintformV As String * 5
'   minissue As String * 4
'   maxissue As String * 5
'   reorderlvl As String * 8
'   reorderqty As String * 6
'   convfact As String * 5
'   anuse As String * 9
'   message As String * 30
'   therapcode As String * 2
'   extralabel As String * 3      '26Mar95 ASC was interaction
'   stocklvl As String * 9
'   sislistprice As String * 9
'   contprice As String * 9
'   livestockctrl As String * 1
'   leadtime As String * 3
'   loccode As String * 3
'   usagedamping As Single
'   safetyfactor As Single
'   indexed As String * 1         'used to stop transaction logging of stock
'                                 'adjustments on unindexed drugs  ASC 5.5.92
'                                 '18Jul97 CKJ Now used to flag on Data Provision Service  (= "1")
'   recalcatperiodend As String * 1
'   blank As String * 6           '18Jul97 CKJ datelastperiodend*6 stretched and moved below
'   lossesgains As Single
'   'cyclical AS STRING * 1       'not used at present
'   'imprest AS INTEGER           ' "
'   'numofdaysbo AS INTEGER       ' "
'   spare As String * 7           '14Mar95 CKJ -> 7 from 5 by removing worksheeetno chars 20Aug96 ASC
'   dosesperissueunit As Single   '23Dec93 CKJ
'   mlsperpack As Integer         'added for TPN 28Oct91 CKJ
'   ordercycle As String * 2
'   cyclelength As Integer
'   lastreconcileprice As String * 9
'   outstanding As Single         '20Mar93 ASC
'   usethisperiod As Single       'ASC 9Apr93
'   vatrate As String * 1         '24May93 ASC, 23Dec93 CKJ was Single
'   DosingUnits As String * 5     '23Dec93 CKJ
'   ATCCode As String * 8         ' was Prescribing code could be 4 I think
'   UserMsg As String * 2
'
'   MaxInfusionRate As Single     '<---CIVA added ASC 28Mar94
'   MinmgPerml As Single          'ASC 28Mar94 removed dosing info to extend CIVAS
'   InfusionTime As Single
'   mgPerml As Single
'   IVcontainer As String * 1
'   DisplacementVolume As Single  '<---TO HERE
'   'CommentPtr AS INTEGER        'not used at present
'   PILnumber As Integer          '8Jun94 CKJ
'   'pad As String * 1
'   '16May97 ASC
'   datelastperiodend As String * 8 '18Jul97 CKJ Moved from above and stretched to ddmmccyy
'   MinDailyDose As Single
'   MaxDailyDose  As Single
'   MinDoseFrequency As Single
'   MaxDoseFrequency As Single
'   route As String * 20          '12Dec97 expanded - see below
'   'spare2 As String * 20        '12Dec97 replaces Route                <CANCELLED
'   chemical As String * 50
'   local As String * 7           '17Jul97 CKJ Added Local code
'   'NB Reserve 3 bytes for expansion of local code
'   extralocal As String * 3      'ASC/EAC 22Sep97
'
'   DosesPerAdminUnit As Double   'ASC/EAC 22Sep97 for dose range checking '12Dec97 removed as it should have been single precision
'   'spare3 As String * 8         '12Dec97 replaces DosesPerAdminUnit    <CANCELLED
'   adminunit As String * 5       'ASC/EAC 22Sep97
'   'padding As String * 456      'ASC/EAC 22Sep97 taken 13 off for above
'   DPSform As String * 25        '12Dec97 CKJ Added to allow form of drug to be set via DPS
'   'DosesPerAdminUnit As Single  'ASC/EAC 22Sep97 for dose range checking '12Dec97 set to single instead of double
'   'Route As String * 34         '12Dec97 expanded from 20 above
'   '12Dec97 CKJ NB: Returned DosesPerAdminUnit & Route to original position
'   storesdescription As String * 56
'   storespack As String * 5
'   teamworkbtn As Integer
'   StrengthDesc As String * 12     '20Jul98 ASC added for HK only at present
'   loccode2 As String * 3          '20Nov98 TH Added for enhanced stockcontrol
'   lastissued As String * 8        '23Nov98 TH Added
'   lastordered As String * 8       '23Nov98 TH Added
'   CreatedUser As String * 3       '25Nov98 TH Added
'   createdterminal As String * 15  '25Nov98 TH Added
'   createddate As String * 8       '25Nov98 TH Added
'   createdtime As String * 6       '25Nov98 TH Added
'   modifieduser As String * 3      '25Nov98 TH Added
'   modifiedterminal As String * 15 '25Nov98 TH Added
'   modifieddate As String * 8      '25Nov98 TH Added
'   modifiedtime As String * 6      '25Nov98 TH Added
'   batchtracking As String * 1     '22Dec98 CFY
'   stocktakestatus As String * 1   '0/1/2    0 to be done, 1 pending, 2 done
'   laststocktakedate As String * 8 'date as ddmmccyy, only updated at stocktakestatus 2
'   laststocktaketime As String * 6 'time as hhmmss    only updated at stocktakestatus 2
'   pflag As String * 1             '27Jan99 TH
'   issueWholePack As String * 1    '18Feb99 SF added
'   HasFormula As String * 1        '11Oct99 CKJ "Y" "N" " "
'   PIL2 As String * 10             '13Aug01 SF added a secondary PIL field (for CMI enhancement)
'   StripSize As String * 5         '08Jan02 TH Added for Pyxis enhancement (#56462)
'   pipcode As String * 7            ' 28Mar02 ATW PIP is a 7 digit numeric used in many pharmaceutical catalogs in the UK (at least)
'   sparePIP As String * 5           '              spare space in case PIP ever expands.
'   MasterPip As String * 7          ' 22Apr02 ATW Master PIP code for price update reference
'   spareMasterPip As String * 5
'   padding As String * 215          '           227 - (7 + 5)
'End Type             'Total length = 1024 chars

Type DrugParameters
   ProductID As Long
   productstockID As Long
   Code As String * 8
   'Description As String * 56
   'Description_Locked As Boolean  XN 4Jun15 98073 New local stores description
   DrugDescription As String * 56
   LabelDescription As String * 56
   LabelDescription_Locked As Boolean 'AK 22oct08 Added (F0018781)
   inuse As String * 1
   deluserid As String * 3
   tradename As String * 30
   cost As String * 9
   contno As String * 10
   supcode As String * 5
   altsupcode As String * 29
   warcode2 As String * 6
   warcode2_Locked As Boolean 'AK 22oct08 Added (F0018781)
   'ledcode As String * 7     '20Aug09 PJC Extended ledcode from 7 to 20 characters (F0050136)
   ledcode As String * 20     '     "        "
   SisCode As String * 7
   barcode As String * 13
   cyto As String * 1
   civas As String * 1
   formulary As String * 1
   bnf As String * 13

   ReconVol As Single        '<---CIVA added ASC 28Mar94
   ReconAbbr As String * 3
   Diluent1Abbr As String * 3
   Diluent2Abbr As String * 3
   MaxmgPerml As Single      '<---TO HERE

   warcode As String * 6
   warcode_Locked As Boolean 'AK 22oct08 Added (F0018781)
   inscode As String * 6
   inscode_Locked As Boolean 'AK 22oct08 Added (F0018781)
   dircode As String * 6
   labelformat As String * 1  'was labelform ASC 28Mar94
   expiryminutes As Long
   sisstock As String * 1
   ATC As String * 1             '23Dec93 CKJ
   reorderpcksize As String * 5
   PrintformV As String * 5
   minissue As String * 4
   maxissue As String * 5
   reorderlvl As String * 8
   reorderqty As String * 6
   convfact As String * 5
   anuse As String * 9
   message As String * 30
   therapcode As String * 2
   extralabel As String * 3      '26Mar95 ASC was interaction
   stocklvl As String * 9
   sislistprice As String * 9
   contprice As String * 9
   livestockctrl As String * 1
   LeadTime As String * 3
   loccode As String * 3
   usagedamping As Single
   safetyfactor As Single
   indexed As String * 1         'used to stop transaction logging of stock
                                 'adjustments on unindexed drugs  ASC 5.5.92
                                 '18Jul97 CKJ Now used to flag on Data Provision Service  (= "1")
   recalcatperiodend As String * 1
   lossesgains As Single
   dosesperissueunit As Single   '23Dec93 CKJ
   mlsperpack As Single          'added for TPN 28Oct91 CKJ  '09May05 CKJ was Integer
   ordercycle As String * 2
   cyclelength As Integer
   lastreconcileprice As String * 9
   outstanding As Single         '20Mar93 ASC
   usethisperiod As Single       'ASC 9Apr93
   vatrate As String * 1         '24May93 ASC, 23Dec93 CKJ was Single
   DosingUnits As String * 20    '23Dec93 CKJ      '09May05 was 5 now 20
   ATCCode As String * 8         ' was Prescribing code could be 4 I think
   UserMsg As String * 4 '* 2 '15Aug14 TH Extended to 4

   MaxInfusionRate As Single     '<---CIVA added ASC 28Mar94
   MinmgPerml As Single          'ASC 28Mar94 removed dosing info to extend CIVAS
   InfusionTime As Single
   mgPerml As Single
   IVcontainer As String * 1
   DisplacementVolume As Single  '<---TO HERE
   PILnumber As Integer
   datelastperiodend As String * 8 'ddmmccyy
   MinDailyDose As Single
   MaxDailyDose  As Single
   MinDoseFrequency As Single
   MaxDoseFrequency As Single
''   route As String * 20          '12Dec97 expanded - see below     '09May05 no longer read or used - comes from prescription/directions
   chemical As String * 50
   local As String * 20          '09May05 CKJ widened from 7
   
''09May05 CKJ fields not used so removed
''   DosesPerAdminUnit As Double   'ASC/EAC 22Sep97 for dose range checking '12Dec97 removed as it should have been single precision
''   adminunit As String * 5       'ASC/EAC 22Sep97
   DPSform As String * 25        '12Dec97 CKJ Added to allow form of drug to be set via DPS
   storesdescription As String * 56
   storesdescription_Locked As Boolean 'AK 22oct08 Added (F0018781)
   storespack As String * 5
   teamworkbtn As Integer
   StrengthDesc As String * 12     '20Jul98 ASC added for HK only at present
   loccode2 As String * 3
   lastissued As String * 8
   lastordered As String * 8
   CreatedUser As String * 3
   createdterminal As String * 15
   createddate As String * 8
   createdtime As String * 6
   modifieduser As String * 3
   modifiedterminal As String * 15
   modifieddate As String * 8
   modifiedtime As String * 6
   batchtracking As String * 1
   stocktakestatus As String * 1   '0/1/2    0 to be done, 1 pending, 2 done
   laststocktakedate As String * 8 'date as ddmmccyy, only updated at stocktakestatus 2
   laststocktaketime As String * 6 'time as hhmmss    only updated at stocktakestatus 2
   pflag As String * 1
   issueWholePack As String * 1
   PIL2 As String * 10             '13Aug01 SF added a secondary PIL field (for CMI enhancement)
   StripSize As String * 5         '08Jan02 TH Added for Pyxis enhancement (#56462)
   pipcode As String * 7            ' 28Mar02 ATW PIP is a 7 digit numeric used in many pharmaceutical catalogs in the UK (at least)
   sparePIP As String * 5           '              spare space in case PIP ever expands.
   MasterPip As String * 7          ' 22Apr02 ATW Master PIP code for price update reference
   spareMasterPip As String * 5
   
   'SQL Added
   WSupplierProfileID As Long
   SuppRefno As String * 36 '10Oct10 TH Extend supplier reference to 36 chars from 20 (F0094388/RCN545)
   'PrimarySup As Boolean '12Oct06 TH Removed
   LabelInIssueUnits As Boolean
   CanUseSpoon As Boolean
   CanUseSpoon_Locked As Boolean    '9May12 XN TFS33227 User can lock CanUseSpoon option (from DSS on web updates)
   SiteProductDataID As Long  'This is used as a pointer back to the DSS SiteProductDataTable and is used on Updates in the editor
   DSSMasterSiteID As Long  'This keys the product to the 'meta' site in the Master DSS DB
   SupplierTradeName As String * 30 '04Oct06 TH Added
   DrugID As Long '21Nov06 TH Added
   PhysicalDescription As String * 35         '16Jul09 TH Ported 25Jan08 CKJ Added to hold 'Round white scored tablet ASC/500'
   DDDValue   As String * 10       '07Apr10 AJK Ported from v8 (F0072782)
   DDDUnits   As String * 10       '   "
   UserField1   As String * 10     '   "
   UserField2   As String * 10     '   "
   UserField3   As String * 10     '   "
   HIProduct As String * 1         '07Apr10 AJK Added for HIL enhancement (F0072542) Ported in from v8.
   'edilinkcode As Long            '14Apr10 AJK Added for F0072782
   EDILinkCode As String * 13      '27May10 AJK F0061692 Changed to string as it's a barcode that may have leading 0's
   EDIBarcode as String * 14	   '22Jul16 XN Added EDIBarcode 126634
   PASANPCCode As String * 6       '14Apr10 AJK Added for F0072782
   PNExclude As Boolean            '27Jan12 CKJ added
   EyeLabel As Boolean             '31Jan13 TH  Added (TFS 39777) (TFS 55067)
   PSOLabel As Boolean             '06Aug12 TH Added. This is from the supplier profile and specifies whether item can be PSO'ed
   ExpiryWarnDays As Integer       '13Jun13 TH Added (TFS 39884)
   DMandDReference As String * 20  '18Aug14 TH Merged for eHub (TFS 98117)
   LabelDescriptionInPatient As String * 56  '30Apr14 XN alternate label for in-patients (TFS 98073)
   LabelDescriptionOutPatient As String * 56 '05May15 XN alternate label for out-patients (TFS 98073)
   LocalDescription AS String * 56           '20May15 XN local description (TFS 98073)
End Type
'

Function GetProductRSbyID(ByVal productstockID As Long) As ADODB.Recordset
'09May05 plain read with no UI or business logic, returning an ADODB RS

Dim strParameters As String
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource As String = "GetProductRSbyID"

   On Error GoTo ErrHandler
   strParameters = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, productstockID)
   Set GetProductRSbyID = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByProductStockID", strParameters)
Exit Function

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   '
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc

End Function

Function GetProductNL(ByVal productstockID As Long, ByRef d As DrugParameters) As Boolean
'**93** Given the PK, fetch a Product and fill the d structure
'       If the Product is absent then return success = false
'       If the DB is unreachable then raise an error
'       Note that Site is not required since the productstockid is already site specific
'10May12 XN Loaded CanUseSpoon field from DB TFS33227

Dim rs As ADODB.Recordset
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetProductNL"

   On Error GoTo ErrorHandler
   BlankWProduct d
   Set rs = GetProductRSbyID(productstockID)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetProductNL = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function GetNod() As Long
'04Jan05 TH

Dim strParams As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetNod"

   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
   GetNod = gTransport.ExecuteSelectReturnSP(g_SessionID, "WProductCountByLocationID_Site", strParams)

Cleanup:
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function GetProductNLbyProductID(ByVal ProductID As Long, ByRef d As DrugParameters) As Boolean
'**93** Given a ProductID (and site) fetch a Product and fill the d structure
'       If the Product is absent then return success = false
'       If the DB is unreachable then raise an error

Dim rs As ADODB.Recordset
Dim strParams As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetProductNLbyProductID"

   On Error GoTo ErrorHandler
   BlankWProduct d
   
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, ProductID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelect", strParams)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetProductNLbyProductID = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function GetProductNLbyNSV(ByVal NSVCode As String, ByRef d As DrugParameters) As Boolean
'**93** Given an NSVcode, fetch a Product and fill the d structure
'       If the Product is absent then return success = false
'       If the DB is unreachable then raise an error

Dim rs As ADODB.Recordset
Dim strParameters As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetProductNLbyNSV"

   On Error GoTo ErrorHandler
   BlankWProduct d
   
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, NSVCode)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByNSV", strParameters)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetProductNLbyNSV = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function GetProductNLbyBarcode(ByVal barcode As String, ByRef d As DrugParameters) As Boolean
'**93** Given a Barcode, fetch a Product and fill the d structure
'       If the Product is absent then return success = false
'       If the DB is unreachable then raise an error

Dim rs As ADODB.Recordset
Dim strParameters As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetProductNLbyBarcode"

   On Error GoTo ErrorHandler
   BlankWProduct d
   
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 13, barcode)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByBarcode", strParameters)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetProductNLbyBarcode = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function GetProductNLbyEDILinkCode(ByVal EDILinkCode As String, ByRef d As DrugParameters) As Boolean
'27May10 AJK F0061692 Added
'       Given a EDILinkCode, fetch a Product and fill the d structure
'       If the Product is absent then return success = false
'       If the DB is unreachable then raise an error

Dim rs As ADODB.Recordset
Dim strParameters As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetProductNLbyEDILinkCode"

   On Error GoTo ErrorHandler
   BlankWProduct d
   
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, EDILinkCode)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByEDILinkCode", strParameters)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetProductNLbyEDILinkCode = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function


Function PutProductNL(ByRef d As DrugParameters) As Boolean
'09May05 Given a filled WProduct structure write to the DB
'       If ProductID is > 0 then write to that PK else add a new Product
'
'  Product       =>    ProductStock
'---------------    ------------------
'PK ProductID       PK ProductStockID
'                   FK ProductID
'                   FK LocationID_Site
'
'To store row in ProductStock we must have a ProductID which exists in WProduct view
'and there must either be
'  A ProductStockID given which is valid and is the only row in ProductStock with that ProductID for the current site
'or
'  No ProductStockID and no row in ProductStock with that ProductID for the current site
'
'Since creation of a row is solely the preserve of an editor, update alone is supported in PutProductNL
'Oct04 TH Additional to above.
'Also required is a row in the WSupplierProfile table for the given product with the default supplier and the sitecode included
'23Nov05 TH TOMERGE Added storespack
'20Aug09 PJC Amended the ledcode parameter definition length changed from 7 to 20 (F0050136)
'07Apr10 AJK Added new fields for F0072782 & F0072542
'14Apr10 AJK Added fields for F0072782
'10Oct10 TH  Extend supplier reference to 36 chars (F0094388/RCN545)
'27Jan12 CKJ Added PNExclude flag to ProductStock
'31Jan13 TH  Added EyeLabel (TFS 39777) (TFS 55067)- missed in merge (TFS 56917/58425)

Dim success As Boolean
Dim strParam As String
Dim lngResult As Long
Dim blnInsert As Boolean
Dim intloop As Integer
  
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "PutProductNL"

   On Error GoTo ErrorHandler
   
   success = False
   
   'If d.ProductID <= 0 Then
''   If d.ProductID = 0 Then '13Feb06 TH Added
''''      ProductID = gTransport.ADOExecuteInsertSP(g_SessionID, "WProduct", strParam)
''''      success = (ProductID <> 0)
''''      d.ProductID = ProductID
''      popmessagecr "!Can't Update", "ProductID=0"
''      Stop '!!**
''   ''ElseIf d.ProductStockID <= 0 Then
''      ''popmessagecr "!Can't Update", "ProductStockID=0"
''      ''Stop '!!**
''   Else
      If d.productstockID <= 0 Then blnInsert = True
      gTransportConnectionExecute "Begin Transaction"   '10Aug12 CKJ
      strParam = "" _
         & gTransport.CreateInputParameterXML("inuse", trnDataTypeVarChar, 1, d.inuse) _
         & gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, d.cyto) _
         & gTransport.CreateInputParameterXML("formulary", trnDataTypeVarChar, 1, d.formulary) _
         & gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, d.warcode) _
         & gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, d.warcode2) _
         & gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, d.inscode) _
         & gTransport.CreateInputParameterXML("dircode", trnDataTypeVarChar, 6, d.dircode) _
         & gTransport.CreateInputParameterXML("labelformat", trnDataTypeVarChar, 1, d.labelformat) _
         & gTransport.CreateInputParameterXML("extralabel", trnDataTypeVarChar, 3, d.extralabel)
         '04Oct06 TH Added ReorderLvl and ReorderQty - moved from SupplierProfile
      strParam = strParam _
         & gTransport.CreateInputParameterXML("expiryminutes", trnDataTypeint, 4, d.expiryminutes) _
         & gTransport.CreateInputParameterXML("minissue", trnDataTypeVarChar, 4, d.minissue) _
         & gTransport.CreateInputParameterXML("maxissue", trnDataTypeVarChar, 5, d.maxissue) _
         & gTransport.CreateInputParameterXML("lastissued", trnDataTypeVarChar, 8, d.lastissued) _
         & gTransport.CreateInputParameterXML("issueWholePack", trnDataTypeVarChar, 1, d.issueWholePack) _
         & gTransport.CreateInputParameterXML("stocklvl", trnDataTypeVarChar, 9, d.stocklvl) _
         & gTransport.CreateInputParameterXML("sisstock", trnDataTypeVarChar, 1, d.sisstock) _
         & gTransport.CreateInputParameterXML("livestockctrl", trnDataTypeVarChar, 1, d.livestockctrl) _
         & gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, d.reorderlvl) _
         & gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, d.reorderqty) _
         & gTransport.CreateInputParameterXML("ordercycle", trnDataTypeVarChar, 2, d.ordercycle) _
         & gTransport.CreateInputParameterXML("cyclelength", trnDataTypeint, 4, d.cyclelength) _
         & gTransport.CreateInputParameterXML("outstanding", trnDataTypeFloat, 8, d.outstanding) _
         & gTransport.CreateInputParameterXML("loccode", trnDataTypeVarChar, 3, d.loccode) _
         & gTransport.CreateInputParameterXML("loccode2", trnDataTypeVarChar, 3, d.loccode2) _
         & gTransport.CreateInputParameterXML("anuse", trnDataTypeVarChar, 9, d.anuse) _
         & gTransport.CreateInputParameterXML("usethisperiod", trnDataTypeFloat, 8, d.usethisperiod) _
         & gTransport.CreateInputParameterXML("recalcatperiodend", trnDataTypeVarChar, 1, d.recalcatperiodend) _
         & gTransport.CreateInputParameterXML("datelastperiodend", trnDataTypeVarChar, 8, d.datelastperiodend) _
         & gTransport.CreateInputParameterXML("usagedamping", trnDataTypeFloat, 8, d.usagedamping) _
         & gTransport.CreateInputParameterXML("safetyfactor", trnDataTypeFloat, 8, d.safetyfactor)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("supcode", trnDataTypeVarChar, 5, d.supcode) _
         & gTransport.CreateInputParameterXML("altsupcode", trnDataTypeVarChar, 29, d.altsupcode) _
         & gTransport.CreateInputParameterXML("lastordered", trnDataTypeVarChar, 8, d.lastordered) _
         & gTransport.CreateInputParameterXML("stocktakestatus", trnDataTypeVarChar, 1, d.stocktakestatus) _
         & gTransport.CreateInputParameterXML("laststocktakedate", trnDataTypeVarChar, 8, d.laststocktakedate) _
         & gTransport.CreateInputParameterXML("laststocktaketime", trnDataTypeVarChar, 6, d.laststocktaketime) _
         & gTransport.CreateInputParameterXML("batchtracking", trnDataTypeVarChar, 1, d.batchtracking) _
         & gTransport.CreateInputParameterXML("cost", trnDataTypeVarChar, 9, d.cost) _
         & gTransport.CreateInputParameterXML("lossesgains", trnDataTypeFloat, 8, d.lossesgains)
         
'20Aug09 PJC Amended the ledcode parameter definition length changed from 7 to 20 (F0050136)
         '& gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 7, d.ledcode)
         '15Aug14 Th Extended UserMsg (Drug msg code) to four chars (TFS 97987)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("ledcode", trnDataTypeVarChar, 20, d.ledcode) _
         & gTransport.CreateInputParameterXML("pflag", trnDataTypeVarChar, 1, d.pflag)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("message", trnDataTypeVarChar, 30, d.message) _
         & gTransport.CreateInputParameterXML("UserMsg", trnDataTypeVarChar, 4, d.UserMsg) _
         & gTransport.CreateInputParameterXML("PILnumber", trnDataTypeint, 4, d.PILnumber) _
         & gTransport.CreateInputParameterXML("PIL2", trnDataTypeVarChar, 10, d.PIL2) _
         & gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, d.modifieduser) _
         & gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, "") _
         & gTransport.CreateInputParameterXML("modifieddate", trnDataTypeVarChar, 8, d.modifieddate) _
         & gTransport.CreateInputParameterXML("modifiedtime", trnDataTypeVarChar, 6, d.modifiedtime) _
         & gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 20, d.local) _
         & gTransport.CreateInputParameterXML("CIVAS", trnDataTypeVarChar, 1, d.civas)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("mgperml", trnDataTypeFloat, 8, d.mgPerml) _
         & gTransport.CreateInputParameterXML("maxInfusionrate", trnDataTypeFloat, 8, d.MaxInfusionRate) _
         & gTransport.CreateInputParameterXML("InfusionTime", trnDataTypeFloat, 8, d.InfusionTime) _
         & gTransport.CreateInputParameterXML("Minmgperml", trnDataTypeFloat, 8, d.MinmgPerml) _
         & gTransport.CreateInputParameterXML("Maxmgperml", trnDataTypeFloat, 8, d.MaxmgPerml) _
         & gTransport.CreateInputParameterXML("IVContainer", trnDataTypeVarChar, 1, d.IVcontainer) _
         & gTransport.CreateInputParameterXML("DisplacementVolume", trnDataTypeFloat, 8, d.DisplacementVolume) _
         & gTransport.CreateInputParameterXML("ReconVol", trnDataTypeFloat, 8, d.ReconVol) _
         & gTransport.CreateInputParameterXML("ReconAbbr", trnDataTypeVarChar, 3, d.ReconAbbr) _
         & gTransport.CreateInputParameterXML("Diluent1", trnDataTypeVarChar, 3, d.Diluent1Abbr) _
         & gTransport.CreateInputParameterXML("Diluent2", trnDataTypeVarChar, 3, d.Diluent2Abbr)
         
      strParam = strParam _
         & gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact) _
         & gTransport.CreateInputParameterXML("dosesperissueunit", trnDataTypeFloat, 8, d.dosesperissueunit) _
         & gTransport.CreateInputParameterXML("StoresPack", trnDataTypeVarChar, 5, d.storespack) _
         & gTransport.CreateInputParameterXML("therapcode", trnDataTypeVarChar, 2, d.therapcode) _
         & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID)
'04Oct06 TH removed BNF (now in SiteProductData)
'& gTransport.CreateInputParameterXML("bnf", trnDataTypeVarChar, 13, d.bnf) _
'NOT updated - only written during creation of record
'         & gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, d.CreatedUser) _
'         & gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, d.createdterminal) _
'         & gTransport.CreateInputParameterXML("createddate", trnDataTypeVarChar, 8, d.createddate) _
'         & gTransport.CreateInputParameterXML("createdtime", trnDataTypeVarChar, 6, d.createdtime)
      '07Apr10 AJK Added for F0072782 & F0072542
      strParam = strParam _
         & gTransport.CreateInputParameterXML("DDDValue", trnDataTypeVarChar, 10, d.DDDValue) _
         & gTransport.CreateInputParameterXML("DDDUnits", trnDataTypeVarChar, 10, d.DDDUnits) _
         & gTransport.CreateInputParameterXML("UserField1", trnDataTypeVarChar, 10, d.UserField1) _
         & gTransport.CreateInputParameterXML("UserField2", trnDataTypeVarChar, 10, d.UserField2) _
         & gTransport.CreateInputParameterXML("UserField3", trnDataTypeVarChar, 10, d.UserField3) _
         & gTransport.CreateInputParameterXML("HIProduct", trnDataTypeChar, 1, d.HIProduct)
      '14Apr10 AJK Added for F0072782
      '27May10 AJK Changed EDILinkCode datatype for F0061692
      '27Jan12 CKJ added PNExclude
      '06Aug12 TH  Added PSO
      '31Jan13 TH  Added EyeLabel (TFS 39777) (TFS 55067)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("PIPCode", trnDataTypeVarChar, 7, d.pipcode) _
         & gTransport.CreateInputParameterXML("MasterPIP", trnDataTypeVarChar, 7, d.MasterPip) _
         & gTransport.CreateInputParameterXML("EDILinkCode", trnDataTypeVarChar, 13, d.EDILinkCode) _
         & gTransport.CreateInputParameterXML("PNExclude", trnDataTypeBit, 1, d.PNExclude) _
         & gTransport.CreateInputParameterXML("EyeLabel", trnDataTypeBit, 1, d.EyeLabel) _
         & gTransport.CreateInputParameterXML("PSOLabel", trnDataTypeBit, 1, d.PSOLabel) _
         & gTransport.CreateInputParameterXML("ExpiryWarnDays", trnDataTypeint, 4, d.ExpiryWarnDays)
      

      If blnInsert Then
         'Insert
         strParam = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, d.ProductID) _
                  & gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strParam
         '21Nov06 TH Removed ProductID
         'strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & strParam
         lngResult = gTransport.ExecuteInsertSP(g_SessionID, "ProductStock", strParam)
         d.productstockID = lngResult '05Jul05 TH Added
      Else
         'Update
         '21Nov06 TH Removed ProductID
         strParam = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, d.ProductID) & strParam
         strParam = gTransport.CreateInputParameterXML("ProductStockID", trnDataTypeint, 4, d.productstockID) & strParam
         If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
            If d.WSupplierProfileID <> -100 Then
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pProductStockUpdateUnderLock", strParam)
            Else
               lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pProductStockUpdateWithSupUnderLock", strParam)
            End If
            If lngResult = -1000 Then
            'This is the return flag to indicate that the lock has expired
               Err.Number = -1000
               Err.Description = "Row Lock Failure"
              '' GoTo ErrorHandler '16May06 TH Added
            End If
         Else
            lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "ProductStock", strParam)
         End If
      End If
      
      If d.WSupplierProfileID <> -100 Then '11Oct06 TH Added as flag to prevent supplier profile save from change of primary supplier in editor
         If d.WSupplierProfileID <= 0 Then blnInsert = True
   'NOT updated - currently held in SiteProductData
   '         & gTransport.CreateInputParameterXML("LabelInIssueUnits", trnDataTypeBit, 1, d.LabelInIssueUnits) _
   '         & gTransport.CreateInputParameterXML("CanUseSpoon", trnDataTypeBit, 1, d.CanUseSpoon)
   
   '04Oct06 TH REmoved these fields to core stock line
   '& gTransport.CreateInputParameterXML("ReorderLvl", trnDataTypeVarChar, 8, d.reorderlvl) _
   '         & gTransport.CreateInputParameterXML("ReorderQty", trnDataTypeVarChar, 6, d.reorderqty) _

   '12Oct06 TH Removed Primary sup as it is not used. THe primary supplier is inferred ONLY from the supcode in the productstock record !
   '& gTransport.CreateInputParameterXML("PrimarySup", trnDataTypeBit, 1, d.PrimarySup) _

         'The following are now removed to the supplier profile table - not stored any longer in the ProductStock table
         strParam = "" _
            & gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, d.SisCode) _
            & gTransport.CreateInputParameterXML("SupCode", trnDataTypeVarChar, 5, d.supcode) _
            & gTransport.CreateInputParameterXML("ContNo", trnDataTypeVarChar, 10, d.contno) _
            & gTransport.CreateInputParameterXML("ReorderPckSize", trnDataTypeVarChar, 5, d.reorderpcksize) _
            & gTransport.CreateInputParameterXML("SisListPrice", trnDataTypeVarChar, 9, d.sislistprice) _
            & gTransport.CreateInputParameterXML("ContPrice", trnDataTypeVarChar, 9, d.contprice)
         strParam = strParam _
            & gTransport.CreateInputParameterXML("LeadTime", trnDataTypeVarChar, 3, d.LeadTime) _
            & gTransport.CreateInputParameterXML("LastReconcilePrice", trnDataTypeVarChar, 9, d.lastreconcileprice) _
            & gTransport.CreateInputParameterXML("SupplierTradeName", trnDataTypeVarChar, 30, d.SupplierTradeName) _
            & gTransport.CreateInputParameterXML("SuppRefNo", trnDataTypeVarChar, 36, d.SuppRefno) _
            & gTransport.CreateInputParameterXML("VatRate", trnDataTypeVarChar, 1, d.vatrate)
         
         If blnInsert Then
            'insert
            strParam = strParam & gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
            lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WSupplierProfile", strParam)
            d.WSupplierProfileID = lngResult
         Else
            'update
            strParam = gTransport.CreateInputParameterXML("WSupplierProfileID", trnDataTypeint, 4, d.WSupplierProfileID) & strParam
            lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WSupplierProfile", strParam)
         End If
      End If  '11Oct06 TH Added
      gTransportConnectionExecute "Commit Transaction"    '10Aug12 CKJ
      success = True    'if no error
''   End If
   
Cleanup:
   On Error Resume Next
   PutProductNL = success
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
   On Error Resume Next
   Do While gTransportIsInTransaction(g_SessionID)    '10Aug12 CKJ
   'For intloop = 1 To 5 '08Dec05 TH
      'Here are going to rollback ay outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"    '10Aug12 CKJ
   Loop
   'Next
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   PutRecordFailure ErrNumber, ErrDescription

   On Error GoTo 0
  
'''Resume Cleanup  '24July06 we are not coming back from this !!

End Function


Function DeleteProductStock(ByVal productstockID As Long) As Integer
'09May05

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String
Const ErrSource As String = "DeleteProductStock"

   On Error GoTo ErrHandler
   DeleteProductStock = gTransport.ExecuteDeleteSP(g_SessionID, "ProductStock", productstockID)
Exit Function

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   'On Error Resume Next
   '
   On Error GoTo 0
   Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc

End Function


Sub CastRecordsetToProduct(ByRef rs As ADODB.Recordset, ByRef d As DrugParameters)
'09May05 Cast record to product structure
'07Apr10 AJK Added fields for F0072542 and F0072782
'14Apr10 AJK Added fields for F0072782
'03Aug10 XN  F0088717 InUse can't be S anymore so force to "Y"
'31Jan13 TH  Added EyeLabel (TFS 39777) (TFS 55067)
'13Jun13 TH  Added field to allow possible warning on batch expiry receipt (TFS 39884)
'30Apr15 XN  alternate label for in-patients (TFS 98073)
'05May15 XN  alternate label for out-patients (TFS 98073)
'20May15 XB  added reading LocalDescription (TFS 98073)

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "CasrRecordSetToProduct"

   On Error Resume Next '''GoTo ErrorHandler
   d.ProductID = rs!ProductID                            'PK
   d.productstockID = GetField(rs!productstockID)        'FK, may be null
   
   d.Code = RtrimGetField(rs!Code)
   'd.Description = RtrimGetField(rs!LabelDescription)    
   'd.Description_Locked = GetField(rs!labeldescription_Locked) XN 4Jun15 98073 New local stores description
   d.DrugDescription = RtrimGetField(rs!Description)
   d.LabelDescription = RtrimGetField(rs!LabelDescription)
   d.LabelDescription_Locked = GetField(rs!labeldescription_Locked) 'AK 22oct08 Added (F0018781)
   d.inuse = RtrimGetField(rs!inuse)
   If d.inuse = "S" Then d.inuse = "Y"                                   '03Aug10 XN F0088717 InUse can't be S anymore so force to "Y"
''   d.deluserid = RtrimGetField(rs!deluserid)
   d.tradename = RtrimGetField(rs!tradename)
   d.cost = RtrimGetField(rs!cost)
   d.contno = RtrimGetField(rs!contno)
   d.supcode = RtrimGetField(rs!supcode)
   d.altsupcode = RtrimGetField(rs!altsupcode)
   d.warcode2 = RtrimGetField(rs!warcode2)
   d.warcode2_Locked = GetField(rs!warcode2_Locked)  'AK 22oct08 Added (F0018781)
   d.ledcode = RtrimGetField(rs!ledcode)
   d.SisCode = RtrimGetField(rs!SisCode)
   d.barcode = RtrimGetField(rs!barcode)
   d.cyto = RtrimGetField(rs!cyto)
   d.civas = RtrimGetField(rs!civas)
   d.formulary = RtrimGetField(rs!formulary)
   d.bnf = RtrimGetField(rs!bnf)

   d.ReconVol = GetField(rs!ReconVol)
   d.ReconAbbr = RtrimGetField(rs!ReconAbbr)
   d.Diluent1Abbr = RtrimGetField(rs!Diluent1)
   d.Diluent2Abbr = RtrimGetField(rs!Diluent2)
   d.MaxmgPerml = GetField(rs!MaxmgPerml)

   d.warcode = RtrimGetField(rs!warcode)
   d.warcode_Locked = GetField(rs!warcode_Locked) 'AK 22oct08 Added (F0018781)
   d.inscode = RtrimGetField(rs!inscode)
   d.inscode_Locked = GetField(rs!inscode_Locked) 'AK 22oct08 Added (F0018781)
   d.dircode = RtrimGetField(rs!dircode)
   d.labelformat = RtrimGetField(rs!labelformat)
   d.expiryminutes = GetField(rs!expiryminutes)
   d.sisstock = RtrimGetField(rs!sisstock)
''   d.ATC = RtrimGetField(rs!ATC)
   d.reorderpcksize = RtrimGetField(rs!reorderpcksize)
   d.PrintformV = RtrimGetField(rs!PrintformV)
   d.minissue = RtrimGetField(rs!minissue)
   d.maxissue = RtrimGetField(rs!maxissue)
   d.reorderlvl = RtrimGetField(rs!reorderlvl)
   d.reorderqty = RtrimGetField(rs!reorderqty)
   d.convfact = RtrimGetField(rs!convfact)
   d.anuse = RtrimGetField(rs!anuse)
   d.message = RtrimGetField(rs!message)
   d.therapcode = RtrimGetField(rs!therapcode)  '26Jun06 TH Reinstated for Tameside reporting
   d.extralabel = RtrimGetField(rs!extralabel)
   d.stocklvl = RtrimGetField(rs!stocklvl)
   d.sislistprice = RtrimGetField(rs!sislistprice)
   d.contprice = RtrimGetField(rs!contprice)
   d.livestockctrl = RtrimGetField(rs!livestockctrl)
   d.LeadTime = RtrimGetField(rs!LeadTime)
   d.loccode = RtrimGetField(rs!loccode)
   d.usagedamping = GetField(rs!usagedamping)
   d.safetyfactor = GetField(rs!safetyfactor)
''   d.indexed = RtrimGetField(rs!indexed)

   d.recalcatperiodend = RtrimGetField(rs!recalcatperiodend)
   d.lossesgains = GetField(rs!lossesgains)
   d.dosesperissueunit = GetField(rs!dosesperissueunit)
   d.mlsperpack = GetField(rs!mlsperpack)
   d.ordercycle = RtrimGetField(rs!ordercycle)
   d.cyclelength = GetField(rs!cyclelength)
   d.lastreconcileprice = RtrimGetField(rs!lastreconcileprice)
   d.outstanding = GetField(rs!outstanding)
   d.usethisperiod = GetField(rs!usethisperiod)
   d.vatrate = RtrimGetField(rs!vatrate)
   d.DosingUnits = RtrimGetField(rs!DosingUnits)
''   d.ATCCode = RtrimGetField(rs!ATCCode)
   d.UserMsg = RtrimGetField(rs!UserMsg)

   d.MaxInfusionRate = GetField(rs!MaxInfusionRate)
   d.MinmgPerml = GetField(rs!MinmgPerml)
   d.InfusionTime = GetField(rs!InfusionTime)
   d.mgPerml = GetField(rs!mgPerml)
   d.IVcontainer = RtrimGetField(rs!IVcontainer)
   d.DisplacementVolume = GetField(rs!DisplacementVolume)
   d.PILnumber = GetField(rs!PILnumber)
   d.datelastperiodend = RtrimGetField(rs!datelastperiodend)
   '03Sep08 TH REinstated these 4 fields (F0027850)
   d.MinDailyDose = GetField(rs!MinDailyDose)
   d.MaxDailyDose = GetField(rs!MaxDailyDose)
   d.MinDoseFrequency = GetField(rs!MinDoseFrequency)
   d.MaxDoseFrequency = GetField(rs!MaxDoseFrequency)
''   d.route = RtrimGetField(rs!route)
''   d.chemical = RtrimGetField(rs!chemical)
   d.local = RtrimGetField(rs!local)

''   d.DosesPerAdminUnit = GetField(rs!DosesPerAdminUnit)
''   d.adminunit = RtrimGetField(rs!adminunit)
   d.DPSform = RtrimGetField(rs!DPSform)
   d.storesdescription = RtrimGetField(rs!storesdescription)
   d.storesdescription_Locked = GetField(rs!storesdescription_Locked) 'AK 22oct08 Added (F0018781)
   d.storespack = RtrimGetField(rs!storespack)
''   d.teamworkbtn = GetField(rs!teamworkbtn)
''   d.StrengthDesc = RtrimGetField(rs!StrengthDesc)
   d.loccode2 = RtrimGetField(rs!loccode2)
   d.lastissued = RtrimGetField(rs!lastissued)
   d.lastordered = RtrimGetField(rs!lastordered)
   d.CreatedUser = RtrimGetField(rs!CreatedUser)
   d.createdterminal = RtrimGetField(rs!createdterminal)
   d.createddate = RtrimGetField(rs!createddate)
   d.createdtime = RtrimGetField(rs!createdtime)
   d.modifieduser = RtrimGetField(rs!modifieduser)
   d.modifiedterminal = RtrimGetField(rs!modifiedterminal)
   d.modifieddate = RtrimGetField(rs!modifieddate)
   d.modifiedtime = RtrimGetField(rs!modifiedtime)
   d.batchtracking = RtrimGetField(rs!batchtracking)
   d.stocktakestatus = RtrimGetField(rs!stocktakestatus)
   d.laststocktakedate = RtrimGetField(rs!laststocktakedate)
   d.laststocktaketime = RtrimGetField(rs!laststocktaketime)
   d.pflag = RtrimGetField(rs!pflag)
   d.issueWholePack = RtrimGetField(rs!issueWholePack)
   d.PIL2 = RtrimGetField(rs!PIL2)
''   d.StripSize = RtrimGetField(rs!StripSize)
   d.pipcode = RtrimGetField(rs!pipcode)
''   d.sparePIP = RtrimGetField(rs!sparePIP)
   d.MasterPip = RtrimGetField(rs!MasterPip)
''   d.spareMasterPip = RtrimGetField(rs!spareMasterPip)
   d.SuppRefno = RtrimGetField(rs!SuppRefno)
   d.WSupplierProfileID = RtrimGetField(rs!WSupplierProfileID)
   'd.PrimarySup = RtrimGetField(rs!PrimarySup)  '12Oct06 TH Removed
   If d.civas = "Y" Then                    '17Jun05 TH If CIVAS then always use dosing units !!
      d.LabelInIssueUnits = 0
   Else
      d.LabelInIssueUnits = RtrimGetField(rs!LabelInIssueUnits)
   End If
   d.CanUseSpoon = RtrimGetField(rs!CanUseSpoon)
   d.CanUseSpoon_Locked = GetField(rs!CanUseSpoon_Locked)    '09May12 XN TFS33227 User can lock CanUseSpoon option (from DSS on web updates)
   d.SiteProductDataID = RtrimGetField(rs!SiteProductDataID)
   d.DSSMasterSiteID = RtrimGetField(rs!DSSMasterSiteID)     '04Oct06 TH Added
   d.SupplierTradeName = RtrimGetField(rs!SupplierTradeName) '04Oct06 TH Added
   d.DrugID = RtrimGetField(rs!DrugID) '21Nov06 TH Added
   d.PhysicalDescription = RtrimGetField(rs!PhysicalDescription) '16Jul09 TH Added
   d.DDDValue = RtrimGetField(rs!DDDValue) '07Apr10 AJK Added
   d.DDDUnits = RtrimGetField(rs!DDDUnits) '07Apr10 AJK Added
   d.UserField1 = RtrimGetField(rs!UserField1) '07Apr10 AJK Added
   d.UserField2 = RtrimGetField(rs!UserField2) '07Apr10 AJK Added
   d.UserField3 = RtrimGetField(rs!UserField3) '07Apr10 AJK Added
   d.HIProduct = RtrimGetField(rs!HIProduct) '07Apr10 AJK Added
   d.EDILinkCode = RtrimGetField(rs!EDILinkCode) '14Apr10 AJK Added F0072782
   d.EDIBarcode = RtrimGetField(rs!EDIBarcode)	'22Jul16 XN 126634
   d.PASANPCCode = RtrimGetField(rs!PASANPCCode) '14Apr10 AJK Added F0072782
   d.PNExclude = GetField(rs!PNExclude)   '27Jan12 CKJ added
   d.EyeLabel = GetField(rs!EyeLabel)     '31Jan13 TH  Added EyeLabel (TFS 39777) (TFS 55067)
   d.PSOLabel = GetField(rs!PSOLabel)     '07Aug12 TH Added 
   d.ExpiryWarnDays = GetField(rs!ExpiryWarnDays)  '13Jun13 TH (TFS 39884)
   '31Mar14 TH Added (eHub TFS) '18Aug14 TH Merged for eHub (TFS 98117)
   If IsNull(rs!DMandDReference) Then  'handle conversion types (as its a bigint
      d.DMandDReference = ""
   Else
      d.DMandDReference = RtrimGetField(rs!DMandDReference)
   End If

    '30Apr14 XN alternate label for in-patients (TFS 98073)
   If IsNull(rs!LabelDescriptionInPatient) Then
      d.LabelDescriptionInPatient = ""
   Else
      d.LabelDescriptionInPatient = GetField(rs!LabelDescriptionInPatient)
   End If
   
    '05May15 XN alternate label for out-patients (TFS 98073)
   If IsNull(rs!LabelDescriptionOutPatient) Then
      d.LabelDescriptionOutPatient = ""
   Else
      d.LabelDescriptionOutPatient = GetField(rs!LabelDescriptionOutPatient)
   End If
   
   '20May15 XN add reading description (TFS 98073)
   If IsNull(rs!LocalDescription) Then
	  d.LocalDescription = ""
   Else
	  d.LocalDescription = GetField(rs!LocalDescription)
   End If
   
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


Sub BlankWProduct(d As DrugParameters)
'09May05 CKJ Replaces cleardrug, which cast between two record types - unsafe now.
'23Apr09 TH  Added supplier profile blanking(F0031619). The ID here was being used as a flag
'            in supplier switching and because this wasnt being cleared this led to profiles not being saved after
'            switching sups in the same session. Also added ref no and suptrade name at same time to tidy up.
'07Apr10 AJK Added HIProduct for F0072542
'14Apr10 AJK Added fields for F0072782
'30Apr15 XN  Added alternate label for in-patients (TFS 98073)
'05May15 XN  Added alternate label for out-patients (TFS 98073)

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "BlankWProduct"

   On Error GoTo ErrorHandler
   
   d.ProductID = 0
   d.productstockID = 0
   d.Code = ""
   'd.Description = ""  XN 4Jun15 98073 New local stores description
   d.DrugDescription = ""
   d.LabelDescription = ""
   d.inuse = ""
   d.deluserid = ""
   d.tradename = ""
   d.cost = ""
   d.contno = ""
   d.supcode = ""
   d.altsupcode = ""
   d.warcode2 = ""
   d.ledcode = ""
   d.SisCode = ""
   d.barcode = ""
   d.cyto = ""
   d.civas = ""
   d.formulary = ""
   d.bnf = ""

   d.ReconVol = 0       '<---CIVA added ASC 28Mar94
   d.ReconAbbr = ""
   d.Diluent1Abbr = ""
   d.Diluent2Abbr = ""
   d.MaxmgPerml = 0     '<---TO HERE

   d.warcode = ""
   d.inscode = ""
   d.dircode = ""
   d.labelformat = ""      ' 1  'was labelform ASC 28Mar94
   d.expiryminutes = 0
   d.sisstock = ""
   d.ATC = ""      ' 1             '23Dec93 CKJ
   d.reorderpcksize = ""
   d.PrintformV = ""
   d.minissue = ""
   d.maxissue = ""
   d.reorderlvl = ""
   d.reorderqty = ""
   d.convfact = ""
   d.anuse = ""
   d.message = ""
   d.therapcode = ""
   d.extralabel = ""
   d.stocklvl = ""
   d.sislistprice = ""
   d.contprice = ""
   d.livestockctrl = ""
   d.LeadTime = ""
   d.loccode = ""
   d.usagedamping = 0
   d.safetyfactor = 0
   d.indexed = ""                'used to stop transaction logging of stock
                                 'adjustments on unindexed drugs  ASC 5.5.92
                                 '18Jul97 CKJ Now used to flag on Data Provision Service  (= "1")
   d.recalcatperiodend = ""
   d.lossesgains = 0
   d.dosesperissueunit = 0
   d.mlsperpack = 0
   d.ordercycle = ""
   d.cyclelength = 0
   d.lastreconcileprice = ""
   d.outstanding = 0
   d.usethisperiod = 0
   d.vatrate = ""      ' 1         '24May93 ASC, 23Dec93 CKJ was Single
   d.DosingUnits = ""
   d.ATCCode = ""
   d.UserMsg = ""

   d.MaxInfusionRate = 0    '<---CIVA added ASC 28Mar94
   d.MinmgPerml = 0         'ASC 28Mar94 removed dosing info to extend CIVAS
   d.InfusionTime = 0
   d.mgPerml = 0
   d.IVcontainer = ""
   d.DisplacementVolume = 0 '<---TO HERE
   d.PILnumber = 0
   d.datelastperiodend = ""      ' 8 'ddmmccyy
   d.MinDailyDose = 0
   d.MaxDailyDose = 0
   d.MinDoseFrequency = 0
   d.MaxDoseFrequency = 0
''   d.route = ""
   d.chemical = ""
   d.local = ""

''   d.DosesPerAdminUnit = 0  'ASC/EAC 22Sep97 for dose range checking '12Dec97 removed as it should have been single precision
''   d.adminunit = ""
   d.DPSform = ""      ' 25        '12Dec97 CKJ Added to allow form of drug to be set via DPS
   d.storesdescription = ""
   d.storespack = ""
   d.teamworkbtn = 0
   d.StrengthDesc = ""      ' 12     '20Jul98 ASC added for HK only at present
   d.loccode2 = ""
   d.lastissued = ""
   d.lastordered = ""
   d.CreatedUser = ""
   d.createdterminal = ""
   d.createddate = ""
   d.createdtime = ""
   d.modifieduser = ""
   d.modifiedterminal = ""
   d.modifieddate = ""
   d.modifiedtime = ""
   d.batchtracking = ""
   d.stocktakestatus = ""      ' 1   '0/1/2    0 to be done, 1 pending, 2 done
   d.laststocktakedate = ""      ' 8 'date as ddmmccyy, only updated at stocktakestatus 2
   d.laststocktaketime = ""      ' 6 'time as hhmmss    only updated at stocktakestatus 2
   d.pflag = "Y"     ' 1        '01Feb99 TH (reconcile if zero priced - default is yes)
   d.issueWholePack = ""
   d.PIL2 = ""      ' 10             '13Aug01 SF added a secondary PIL field (for CMI enhancement)
   d.StripSize = ""      ' 5         '08Jan02 TH Added for Pyxis enhancement (#56462)
   d.pipcode = ""      ' 7            ' 28Mar02 ATW PIP is a 7 digit numeric used in many pharmaceutical catalogs in the UK (at least)
   d.sparePIP = ""      ' 5           '              spare space in case PIP ever expands.
   d.MasterPip = ""      ' 7          ' 22Apr02 ATW Master PIP code for price update reference
   d.spareMasterPip = ""
   d.LabelInIssueUnits = False
   d.CanUseSpoon = False
   d.SiteProductDataID = 0 '07Dec05 TH Added
   d.DSSMasterSiteID = 0   '04Oct06 TH Added
   d.DrugID = 0 '21Nov06 TH Added
   d.WSupplierProfileID = 0   '23Apr09 TH Added (F0031619)
   d.SupplierTradeName = ""   '      "
   d.SuppRefno = ""           '      "
   d.PhysicalDescription = "" '16Jul09 TH Added
   d.DDDUnits = "" '07Apr10 AJK Added
   d.DDDValue = "" '07Apr10 AJK Added
   d.UserField1 = ""  '07Apr10 AJK Added
   d.UserField2 = "" '07Apr10 AJK Added
   d.UserField3 = "" '07Apr10 AJK Added
   d.HIProduct = "" '07Apr10 AJK Added
   d.EDILinkCode = "" '14Apr10 AJK Added F0072782
   d.EDIBarcode = "" '22Jul16 XN Added 126634
   d.PASANPCCode = "" '14Apr10 AJK Added F0072782
   d.PNExclude = False '27Jan12 CKJ added PNExclude
   d.PSOLabel = False   '07Aug12 TH Added
   d.EyeLabel = False   '24Feb13 TH Added
   d.ExpiryWarnDays = 0 '13Jun13 TH Added
   d.LabelDescriptionInPatient = "" '01May15 XN alternate label to use for in-patient (TFS 98073)
   d.LabelDescriptionOutPatient = "" '05May15 XN alternate label to use for out-patient (TFS 98073)
   d.LocalDescription = "" ' 20May15 XN add local label description

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


Function ProductLookup(ByVal indexname As String, ByVal lookup As String, ByVal wildcard As Boolean, ByVal otherroutes As Boolean) As ADODB.Recordset
'**93** Given a code and field name, fetch RS of Products
'       If the Product is absent then return empty RS
'       If the DB is unreachable then raise an error
'       indexname       exact    rowcount
'       ------------    -----    --------
'       nsvcode           Y
'       barcode           Y
'       description       N
'       code              N
'       bnf               N
'       local             Y
'       tradename         N
'       VMPAMPAMPP        Y
'
' Returns
'       recordset of products
'
'06May10 AJK F0073627 Added otherroutes parameter


Dim strParameters As String

Dim NSVCode As String
Dim barcode As String
Dim Description As String
Dim Code As String
Dim bnf As String
Dim localcode As String
Dim tradename As String
Dim inexact As String

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "ProductLookup"

   On Error GoTo ErrorHandler
   
   If UCase$(indexname) = "VMPAMPAMPP" Then     'lookup ProductFamily from a ProductID which may be any of Chemical, Moeity, VMP, AMP or an AMPP
      strParameters = _
         gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
         gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, CLng(lookup)) & _
         gTransport.CreateInputParameterXML("ProductRouteID", trnDataTypeint, 4, CLng(OCXheap("ProductRouteID", "0"))) '03Sep08 TH Added new param to filter on route (F0031980)
         
'      Set ProductLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLookupByProductID_VMPorAMP", strParameters)
      '06May10 AJK F0073627 Load other routes if indicated
      If otherroutes Then
         Set ProductLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLookupByProductID_VMPorAMP_OtherRoutes", strParameters)
      Else
         Set ProductLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLookupByProductID_VMPorAMP", strParameters)
      End If
   Else
      NSVCode = ""
      barcode = ""
      Description = ""
      Code = ""
      bnf = ""
      localcode = ""
      tradename = ""
      
      inexact = "%"
      If wildcard Then lookup = inexact & lookup
      
      Select Case LCase$(indexname)
         Case "nsvcode": NSVCode = lookup
         Case "barcode": barcode = lookup
         Case "description": Description = lookup & inexact
         Case "code": Code = lookup & inexact
         Case "bnf": bnf = lookup & inexact  '31Jan08 TH Reinstated
         Case "local": localcode = lookup
         Case "tradename": tradename = lookup & inexact
         Case Else
            Err.Raise 32767, ErrSource, "ProductLookup called with invalid index: " & indexname
      End Select
            
      '01Apr07 TH Now initialise new search to allow secondary barcode lookup from here.
      If LCase$(indexname) = "barcode" Then
          strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                          gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 13, barcode)
         Set ProductLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductSelectByAllBarcodes", strParameters)
      Else
         strParameters = _
         gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
         gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, NSVCode) & _
         gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, barcode) & _
         gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 255, Description) & _
         gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, Code) & _
         gTransport.CreateInputParameterXML("local", trnDataTypeVarChar, 7, localcode) & _
         gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, tradename) & _
         gTransport.CreateInputParameterXML("bnf", trnDataTypeVarChar, 13, bnf) '31Jan08 TH reinstated

         Set ProductLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductLookupByCriteria", strParameters)
      End If
   End If
   
Cleanup:
   'On Error Resume Next
   '
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Function PutSiteProductDataNL(ByRef d As DrugParameters, siteProductData() As Boolean) As Boolean
'24Jun05 TH Written
'03Sep08 TH Added (F0027850) Added new (old)  dose range fields.
'14Apr10 AJK Added field for F0072782
'10May12 XN  Added saving CanUseSpoon field to DB TFS33227

Dim success As Boolean
Dim strParam As String
Dim dummy As Long
Dim lngSiteProductDataEditableID As Long
Dim blnInsert As Boolean
Dim lngDSSMasterSiteID As Long
Dim DSSDrugID As Long
  
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "PutSiteProductDataNL"
'& gTransport.CreateInputParameterXML("labeldescription", trnDataTypeVarChar, 56, d.labeldescription) _


   On Error GoTo ErrorHandler
   
   
   success = False
''   'First we will need to get the ID associated with the editable table 'No More my friend
''   strParam = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
''              gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, d.SisCode)
''   lngSiteProductDataEditableID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pSiteProductDataEditableReturnIDbySiscodeandSiteID", strParam)
   
   
   'If d.ProductID <= 0 Then
''   If d.ProductID = 0 Then '13Feb06 TH Added
''''      ProductID = gTransport.ADOExecuteInsertSP(g_SessionID, "WProduct", strParam)
''''      success = (ProductID <> 0)
''''      d.ProductID = ProductID
''      popmessagecr "!Can't Update", "ProductID=0"
''      Stop '!!**
''   'ElseIf d.ProductStockID <= 0 Then
''   ElseIf d.SiteProductDataID <= 0 Then
   If d.SiteProductDataID <= 0 Then
      'popmessagecr "!Can't Update", "ProductStockID=0"
      'Stop '!!**
      blnInsert = True
      '20Feb07 TH Moved from below
      strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
      d.DSSMasterSiteID = lngDSSMasterSiteID
       'AS this an insert then we will need to derive the DSSMasterSiteID using the existing locationID_Site
      If d.DrugID = 0 Then '12Dec06 TH added as we could have an insert from the 999 file - these are already drugID mapped
         ''strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
         ''lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
         'If this is a new productStock line then we MUST create a new siteproductdata record
         'NO, if there is one in the mapper (with a ProductID then perhaps we can link on this ?)
         'N.B. **** This can be revisited later, but for now create a new row.
         'A new row needs a DrugID number. Use a setting to get a pointer value. This should be set as a v.high figure
         'to prevent duplication with existing DSSed Products.
         ''GetPointer dispdata$ & "\DrugID", DSSDrugID, True
         d.DSSMasterSiteID = lngDSSMasterSiteID '
         On Error GoTo DrugIDErr
         'GetPointerSQL dispdata$ & "\DrugID", DSSDrugID, True
         GetPointerSQL rootpath$ & "\DrugID", DSSDrugID, True '20Feb06 TH Replaced (to handle multistockholdings across master site !)
         If DSSDrugID = 0 Then GoTo DrugIDErr '19Feb07 TH This needs to be present !!!
         d.DrugID = DSSDrugID '21Nov06 TH Added
         On Error GoTo ErrorHandler
      End If
   Else
      'Update. There must be a siteProductData row here, so we can get the existing DrugID here if necessary
      'If we have a custom update then we will just keep the existing DrugID
      
   End If
      '10Aug12 CKJ gTransport.Connection.Execute "Begin Transaction"
      
      strParam = "" _
         & gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, d.barcode) _
         & gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, d.SisCode) _
         & gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, d.Code) _
         & gTransport.CreateInputParameterXML("LabelDescription", trnDataTypeVarChar, 255, d.LabelDescription) _
         & gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, d.tradename) _
         & gTransport.CreateInputParameterXML("printformv", trnDataTypeVarChar, 5, d.PrintformV) _
         & gTransport.CreateInputParameterXML("storesdescription", trnDataTypeVarChar, 56, d.storesdescription)
      strParam = strParam _
         & gTransport.CreateInputParameterXML("convfact", trnDataTypeint, 4, d.convfact) _
         & gTransport.CreateInputParameterXML("mlsperpack", trnDataTypeFloat, 8, d.mlsperpack) _
         & gTransport.CreateInputParameterXML("cyto", trnDataTypeVarChar, 1, d.cyto) _
         & gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, d.warcode) _
         & gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, d.warcode2) _
         & gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, d.inscode) _
         & gTransport.CreateInputParameterXML("DosesperIssueUnit", trnDataTypeFloat, 8, d.dosesperissueunit) _
         & gTransport.CreateInputParameterXML("DosingUnits", trnDataTypeVarChar, 20, d.DosingUnits) _
         & gTransport.CreateInputParameterXML("DPSForm", trnDataTypeVarChar, 4, Left$(d.DPSform, 4)) _
         & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID) _
         & gTransport.CreateInputParameterXML("LabelInIssueUnits", trnDataTypeVarChar, 1, Iff(d.LabelInIssueUnits, "1", "0")) _
         & gTransport.CreateInputParameterXML("Canusespoon", trnDataTypeVarChar, 1, Iff(d.CanUseSpoon, "1", "0"))
      '04Oct06 TH Added two extra fields
      strParam = strParam _
         & gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, d.DSSMasterSiteID) _
         & gTransport.CreateInputParameterXML("BNF", trnDataTypeVarChar, 13, d.bnf)
      '21Nov06 TH Added
       strParam = strParam _
         & gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, d.ProductID)
      '03Sep08 TH Added (F0027850)
       strParam = strParam _
         & gTransport.CreateInputParameterXML("MinDailyDose", trnDataTypeint, 4, d.MinDailyDose) _
         & gTransport.CreateInputParameterXML("MaxDailyDose", trnDataTypeint, 4, d.MaxDailyDose) _
         & gTransport.CreateInputParameterXML("MinDoseFrequency", trnDataTypeint, 4, d.MinDoseFrequency) _
         & gTransport.CreateInputParameterXML("MaxDoseFrequency", trnDataTypeint, 4, d.MaxDoseFrequency)
      '22oct08 AK Added (F0018781)
       strParam = strParam _
         & gTransport.CreateInputParameterXML("warcode_Locked", trnDataTypeBit, 1, d.warcode_Locked) _
         & gTransport.CreateInputParameterXML("warcode2_Locked", trnDataTypeBit, 1, d.warcode2_Locked) _
         & gTransport.CreateInputParameterXML("inscode_Locked", trnDataTypeBit, 1, d.inscode_Locked) _
         & gTransport.CreateInputParameterXML("StoresDescription_Locked", trnDataTypeBit, 1, d.storesdescription_Locked) _
         & gTransport.CreateInputParameterXML("LabelDescription_Locked", trnDataTypeBit, 1, d.LabelDescription_Locked)
      '09May12 AK Added (TFS33227)
       strParam = strParam _
         & gTransport.CreateInputParameterXML("CanUseSpoon_Locked", trnDataTypeBit, 1, d.CanUseSpoon_Locked)
      '16Jul09 TH Added (Rpt Disp)
       strParam = strParam _
         & gTransport.CreateInputParameterXML("PhysicalDescription", trnDataTypeVarChar, 35, d.PhysicalDescription)
      '14Apr10 AJK Added for F0072782
       strParam = strParam _
         & gTransport.CreateInputParameterXML("PASANPCCode", trnDataTypeVarChar, 6, d.PASANPCCode)

      If d.SiteProductDataID > 0 Then
         'Update
         strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, d.SiteProductDataID) & strParam
         lngSiteProductDataEditableID = gTransport.ExecuteUpdateSP(g_SessionID, "SiteProductData", strParam)
      Else
         'Insert
         'strParam = strParam & gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID)

         lngSiteProductDataEditableID = gTransport.ExecuteInsertSP(g_SessionID, "SiteProductData", strParam)
         'We Need Here to add the new DrugID into the AMPP_MAPPER table
'''         strParam = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, d.ProductID) _
'''                  & gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, DSSDrugID)
'''         dummy = gTransport.ExecuteInsertLinkSP(g_SessionID, "DSS_AMPPMapper", strParam)
         d.SiteProductDataID = lngSiteProductDataEditableID
                  
      End If
      '10Aug12 CKJ gTransport.Connection.Execute "Commit Transaction"
      success = True    'if no error
'   End If
   
Cleanup:
   On Error Resume Next
   PutSiteProductDataNL = success
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error Resume Next
   Do While gTransportIsInTransaction(g_SessionID)    '10Aug12 CKJ
   'For intloop = 1 To 5 '08Dec05 TH
      'Here are going to rollback ay outstanding transactions prior to unloading completely
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"    '10Aug12 CKJ
   Loop
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
   PutRecordFailure ErrNumber, ErrDescription
Resume Cleanup

DrugIDErr:
 On Error Resume Next
   Do While gTransportIsInTransaction(g_SessionID)    '10Aug12 CKJ
      If gTransportIsInTransaction(g_SessionID) Then gTransportConnectionExecute "Rollback Transaction"    '10Aug12 CKJ
   Loop
   On Error GoTo 0
   PutRecordFailure 9000, "DrugID is missing from The WFilePointers Table. Cannot Save Product Row"
End Function
Function isAMPP(ByVal lngProductID As Long) As Boolean
'13Jul05 TH Written. Just returns whether product is AMPP level

Dim strParams As String
Dim lngResult As Long
Dim blnResult As Boolean

   blnResult = False

   strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsProductAMPPbyProductID", strParams)
   
   If lngResult > 0 Then blnResult = True
   
   isAMPP = blnResult


End Function
Function CheckAMPPMapped(ByVal lngProductID As Long) As Boolean
'13Jul05 TH Written. Just returns whether product is in DSS_AMPPMapper table

Dim strParams As String
Dim lngResult As Long
Dim blnResult As Boolean

   blnResult = False

   strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsProductDSS_AMPPMapped", strParams)
   
   If lngResult > 0 Then blnResult = True
   
   CheckAMPPMapped = blnResult


End Function
Function isTM(ByVal lngProductID As Long) As Boolean
'13Jul05 TH Written. Just returns whether product is AMPP level

Dim strParams As String
Dim lngResult As Long
Dim blnResult As Boolean

   blnResult = False

   strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsProductTMbyProductID", strParams)
   
   If lngResult > 0 Then blnResult = True
   
   isTM = blnResult


End Function

Function GetProductStockRowsbyTMProductID(ByVal lngProductID As Long) As ADODB.Recordset
'13Jul05 TH Written. Returns all stock rows for a TM ID

Dim strParams As String
Dim lngResult As Long
Dim rsResult As ADODB.Recordset

   'blnResult = False

   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pGetProductStockRowsbyTMProductID", strParams)
   
   'If lngResult > 0 Then blnResult = True
   
   Set GetProductStockRowsbyTMProductID = rsResult


End Function

Function GetProductRSByNSV(ByVal vstrNSV As String) As ADODB.Recordset
'20Apr10 AJK Written F0077124. Returns all WProduct rows for a given NSVCode, regardless of Site
Dim strParams As String
Dim rsResult As ADODB.Recordset

    strParams = gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, vstrNSV) & _
                gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
    Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWProducSelectAllSitesByNSV", strParams)
    Set GetProductRSByNSV = rsResult

End Function

Function GetProductRSByDrugID(ByVal vlngDrugID As String) As ADODB.Recordset
'20Apr10 AJK Written F0077124. Returns all WProduct rows for a given DrugID, regardless of Site
Dim strParams As String
Dim rsResult As ADODB.Recordset

    strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, vlngDrugID) & _
                gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
    Set rsResult = gTransport.ExecuteSelectSP(g_SessionID, "pWProducSelectAllSitesByDrugID", strParams)
    Set GetProductRSByDrugID = rsResult

End Function


Function isNMP(ByVal lngProductID As Long) As Boolean
'13Jul05 TH Written. Just returns whether product is NMP level

Dim strParams As String
Dim lngResult As Long
Dim blnResult As Boolean

   blnResult = False

   strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsProductNMPbyProductID", strParams)
   
   If lngResult > 0 Then blnResult = True
   
   isNMP = blnResult


End Function

Function isNMPP(ByVal lngProductID As Long) As Boolean
'26Jan06 TH Written. Just returns whether product is NMPP level

Dim strParams As String
Dim lngResult As Long
Dim blnResult As Boolean

   blnResult = False

   strParams = gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, lngProductID)
   lngResult = gTransport.ExecuteSelectReturnSP(g_SessionID, "pIsProductNMPPbyProductID", strParams)
   
   If lngResult > 0 Then blnResult = True
   
   isNMPP = blnResult


End Function
Function ProductMasterLookup(ByVal indexname As String, ByVal lookup As String, ByVal wildcard As Boolean) As ADODB.Recordset
'**93** Given a code and field name, fetch RS of Products
'       If the Product is absent then return empty RS
'       If the DB is unreachable then raise an error
'       indexname       exact    rowcount
'       ------------    -----    --------
'       nsvcode           Y
'       barcode           Y
'       description       N
'       code              N
'       bnf               N
'       local             Y
'       tradename         N
'       VMPAMPAMPP        Y
'
' Returns
'       recordset of products
'

Dim strParameters As String

Dim NSVCode As String
Dim barcode As String
Dim Description As String
Dim Code As String
Dim bnf As String
Dim localcode As String
Dim tradename As String
Dim inexact As String

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "ProductLookup"

   On Error GoTo ErrorHandler
   
   If UCase$(indexname) = "VMPAMPAMPP" Then     'lookup ProductFamily from a ProductID which may be any of Chemical, Moeity, VMP, AMP or an AMPP
      strParameters = _
         gTransport.CreateInputParameterXML("ProductID", trnDataTypeint, 4, CLng(lookup))
         
      Set ProductMasterLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductMasterLookupByProductID_VMPorAMP", strParameters)
   Else
      NSVCode = ""
      barcode = ""
      Description = ""
      Code = ""
      bnf = ""
      localcode = ""
      tradename = ""
      
      inexact = "%"
      If wildcard Then lookup = inexact & lookup
      
      Select Case LCase$(indexname)
         Case "nsvcode": NSVCode = lookup
         Case "barcode": barcode = lookup
         Case "description": Description = lookup & inexact
         Case "code": Code = lookup & inexact
         'Case "bnf": bnf = lookup & inexact
         Case "local": localcode = lookup
         Case "tradename": tradename = lookup & inexact
         Case Else
            Err.Raise 32767, ErrSource, "ProductLookup called with invalid index: " & indexname
         End Select
            
      strParameters = _
         gTransport.CreateInputParameterXML("siscode", trnDataTypeVarChar, 7, NSVCode) & _
         gTransport.CreateInputParameterXML("barcode", trnDataTypeVarChar, 13, barcode) & _
         gTransport.CreateInputParameterXML("description", trnDataTypeVarChar, 255, Description) & _
         gTransport.CreateInputParameterXML("code", trnDataTypeVarChar, 8, Code) & _
         gTransport.CreateInputParameterXML("tradename", trnDataTypeVarChar, 30, tradename)
         'gTransport.CreateInputParameterXML("bnf", trnDataTypeVarChar, 13, bnf) & _

      Set ProductMasterLookup = gTransport.ExecuteSelectSP(g_SessionID, "pWProductMasterLookupByCriteria", strParameters)
   End If
   
Cleanup:
   'On Error Resume Next
   '
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function
Function GetDrugMaster(ByVal SiteProductDataID As Long, ByRef d As DrugParameters) As Boolean
'**93** Given a SiteProductDataID fetch a Master Product and fill the d structure with this plus other defaults
'       If the row is absent then return success = false
'       If the DB is unreachable then raise an error

Dim rs As ADODB.Recordset
Dim strParams As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "GetDrugMaster"

   On Error GoTo ErrorHandler
   BlankWProduct d
   
   strParams = gTransport.CreateInputParameterXML("SiteProductData", trnDataTypeint, 4, SiteProductDataID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDataSelectforDrugMaster", strParams)

   If Not rs Is Nothing Then     'use returned recordset
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            CastRecordsetToProduct rs, d
            GetDrugMaster = True
         End If
      End If
   End If
   
Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup

End Function

Public Sub FillDrugParamswithDSSSiteData(ByRef d As DrugParameters, ByVal SiteID As Long, ByVal DrugID As Long)
'20Feb07 TH Written
'This is used to overlay the DSS (SiteProductData) Fields for a site that is importing a
'drug from the master drug file, but that stockline pre- exists in another stockholding on
'this DSS site. It needs the SiteProductDataID to ensure no duplication. Also NSVCode ?
'Well we will take all existing fields to be sure !!

Dim strParam As String
Dim lngDSSMasterSiteID As Long
Dim rsSiteProductData As ADODB.Recordset


      strParam = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, SiteID)
      lngDSSMasterSiteID = gTransport.ExecuteSelectReturnSP(g_SessionID, "pGetDSSMasterSiteIDbySiteID", strParam)
         
      If lngDSSMasterSiteID > 0 Then
         strParam = gTransport.CreateInputParameterXML("DSSMasterSiteID", trnDataTypeint, 4, lngDSSMasterSiteID) & _
                    gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, DrugID)
         
         Set rsSiteProductData = gTransport.ExecuteSelectSP(g_SessionID, "pSiteProductDatabyDSSMasterSiteIDandDrugID", strParam)
         If Not rsSiteProductData Is Nothing Then     'use returned recordset
            If rsSiteProductData.State = adStateOpen Then
               If rsSiteProductData.RecordCount <> 0 Then
                  CastRecordsetToProduct rsSiteProductData, d
               End If
            End If
         End If
      End If
         
         
         
         

End Sub
 
Public Function AddAlternativeBarcode(ByVal SiteProductDataID As Long, ByVal strBarcode As String) As Long
'01Apr07 TH Written
'This is used to overlay the DSS (SiteProductData) Fields for a site that is importing a
'drug from the master drug file, but that stockline pre- exists in another stockholding on
'this DSS site. It needs the SiteProductDataID to ensure no duplication. Also NSVCode ?
'Well we will take all existing fields to be sure !!

Dim strParam As String
'Dim lngDSSMasterSiteID As Long
'Dim rsSiteProductData As ADODB.Recordset

      AddAlternativeBarcode = 0
      strParam = gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, SiteProductDataID) & _
                 gTransport.CreateInputParameterXML("Alias", trnDataTypeVarChar, 13, strBarcode)
      AddAlternativeBarcode = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWAlternativeBarcodeAdd", strParam)
         
    

End Function

Public Function DeleteAlternativeBarcode(ByVal SiteProductDataAliasID As Long) As Long
'01Apr07 TH Written
'This is used to overlay the DSS (SiteProductData) Fields for a site that is importing a
'drug from the master drug file, but that stockline pre- exists in another stockholding on
'this DSS site. It needs the SiteProductDataID to ensure no duplication. Also NSVCode ?
'Well we will take all existing fields to be sure !!

Dim strParam As String
'Dim lngDSSMasterSiteID As Long
'Dim rsSiteProductData As ADODB.Recordset

      DeleteAlternativeBarcode = 0
      'strParam = gTransport.CreateInputParameterXML("SiteProductDataAliasID", trnDataTypeint, 4, SiteProductDataAliasID)
      DeleteAlternativeBarcode = gTransport.ExecuteDeleteSP(g_SessionID, "SiteProductDataAlias", SiteProductDataAliasID)
         
    

End Function
