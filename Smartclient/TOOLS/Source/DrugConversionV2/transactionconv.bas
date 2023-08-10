Attribute VB_Name = "DrugConversion"
'------------------------------------- Drug Conversion V2 ---------------------------------------
'16Aug12 CKJ Added gTransportConnectionExecute, gTransportIsInTransaction for web transport layer
'            Although this program does not use this layer, it uses the standard WProductIO
'            which avoids making direct calls to the connection object, since this is not present
'            client-side when the web transport is in use. Calls copied verbatim from corelib.

Option Explicit

Type transaction
   revisionlevel As String * 2  ' new version number of the transaction
   patid As String * 10
   caseno As String * 10        ' new CaseNo
   SisCode As String * 7
   convfact As String * 5       ' new d.convfact
   IssueUnits As String * 5     ' new d.PrintformV
   dispid As String * 3
   terminal As String * 15      ' new equals name of terminal 15 x space if unknown
   date As String * 8           ' was * 6   format now ddmmyyyy
   Time As String * 6           ' was * 4   add seconds as hhmmss
   Qty As String * 13           ' was * 9   to cope with E nums
   cost As String * 13          ' was * 9   to cope with E nums. Now equals Total Cost
   CostExVAT As String * 13     ' new Total Cost less VAT
   VATcost As String * 13       ' new equals VAT content
   VatCode As String * 1        ' new equals VAT code 0 to 9
   vatrate As String * 5        ' new equals VAT rate as "1.175" or similar
   ward As String * 5           ' was * 4   widened to eventually allow 5 char wards
   consultant As String * 4
   specialty As String * 5      ' new equals specialty code or 5 x space if not known
   prescriber As String * 5     ' new equals prescriber ID
   dircode As String * 12       ' was * 10  ?? any more chars needed?
   kind As String * 1
   site As String * 3
   labeltype As String * 1      'ASC 30Nov92
   containers As String * 4     'ASC 23Jan92 but still not used in Jul97
   Episode As String * 12       ' new ??(Check IBA spec)
   EventNumber As String * 10   ' new ??(Check IBA spec)
   PrescriptionNum As String * 10  ' new long int is ~4,000,000,000 max
   BatchNum As String * 10      ' new
   ExpiryDate As String * 8     ' new format is ddmmyyyy
   PPflag As String * 1         ' 21Dec98 CFY Added
   stocklvl As String * 9       ' 14Jan99 CFY Added
   custordno As String * 12     ' 18Apr00 CFY Added
   civastype As String * 1      ' 01Jun00 JN Added
   civasamount As String * 5    ' 01Jun00 JN Added
   pad As String * 7           ' 21Dec98 CFY - was 35 - Added PPflag & stocklvl (1+9=10) '01Jun00 JN - removed a further 6 bytes for CIVAS returns enhancement
   crlf As String * 2           ' new separate this from the padding
End Type

Type orderlogstruct
   revisionlevel As String * 2  ' new version number of the transaction
   ordernum As String * 4
   SisCode As String * 7
   convfact As String * 5       ' new d.convfact
   IssueUnits As String * 5     ' new d.PrintformV
   dispid As String * 3
   terminal As String * 15      ' new equals name of terminal 15 x space if unknown
   'dateord As String * 6       ' format still ddmmyy in this version
   'dateordpad As String * 2    ' new ready for format of ddmmyyyy
   dateord As String * 8        '03May98 CKJ Y2K format now ddmmyyyy
   Timeord As String * 6        ' new add seconds as hhmmss
   'daterec As String * 6       ' format still ddmmyy in this version
   'daterecpad As String * 2    ' new ready for format of ddmmyyyy
   daterec As String * 8        '03May98 CKJ Y2K format now ddmmyyyy
   Timerec As String * 6        ' new add seconds as hhmmss
   qtyord As String * 13        ' was * 6   to cope with E nums
   qtyrec As String * 13        ' was * 6   to cope with E nums
   cost As String * 13          ' was * 9   to cope with E nums. Now equals Total Cost
   CostExVAT As String * 13     ' new Total Cost less VAT
   VATcost As String * 13       ' new equals VAT content
   VatCode As String * 1        ' new equals VAT code 0 to 9
   vatrate As String * 5        ' new equals VAT rate as "1.175" or similar
   kind As String * 1
   supcode As String * 5
   site As String * 3
   BatchNum As String * 10      ' new
   ExpiryDate As String * 8     ' new format is ddmmyyyy
   invnum As String * 12        ' was also used for returns code & batch num
   Date3 As String * 8          ' new
   Time3 As String * 6          ' new
   Qty3 As String * 13          ' new
   info As String * 12          ' new
   LinkedNum As String * 4      ' new returns, supp orders & req’s link to another order
   ReasonCode As String * 4     ' new
   'pad As String * 28           ' new total length is now 256
   stocklvl As String * 9       '25Jan02 TH Added (#53214)
   pad As String * 19           '    "
   crlf As String * 2           ' new separate this from the padding
End Type


Type supplierstruct
   Code As String * 5
   contractaddress As String * 100
   supaddress As String * 100
   invaddress As String * 100
   conttelno As String * 14
   suptelno As String * 14
   invtelno As String * 14
   discountdesc As String * 70
   discountval As String * 9
   method As String * 1
   ordmessage As String * 50
   avleadtime As String * 4
   contfaxno As String * 14
   supfaxno As String * 14
   '24Oct96 EAC - match mod made in DOS 12Mar96 by ASC
   'invfaxno As String * 14
   'icode as string * 2
   invfaxno As String * 13                                   '@~@~!!
''   pad1 As String * 3           '10Sep96 EAC was icode       '@~@~!!
   name As String * 15
   ptn As String * 1
   psis As String * 1
   fullname As String * 35     '21Mar93 CKJ Added
   discountbelow As String * 4 '  "
   discountabove As String * 4 '  "
   '27Aug96 EAC
   'pad As String * 95
   icode As String * 8                 '10Sep96 EAC
   CostCentre As String * 15           'could be subjective and/or objective code for links
   PrintDeliveryNote As String * 1     'Yes or No
   PrintPickTicket As String * 1       'Yes or No
   suppliertype As String * 1          'e.g. ward, store, external supplier
   OrderOutput As String * 1           'e.g. paper,fax,edi,internal, X25, modem
   ReceiveGoods As String * 1          'Yes or No
   TopupInterval As String * 2         'Number in days
   ATCSupplied As String * 1           'Yes or No
''   pad2 As String * 4                  'WAS Cost code for ward
   topupdate As String * 8
   inuse As String * 1
   wardcode As String * 5              'Cost code for ward      '@~@~!! len 4 in translog
   onCost As String * 3                '19Apr00 JP On Cost as % charged to a ward.
   InPatientDirections As String * 1   '30Mar01 AE  "1" is on, anything else is false.
   'pad As String * 42                  '30Mar01 AE  43 - 1 for inpatient directions flag
   AdHocDelNote As String * 1          '31Oct01 TH Added new field to print delivery note on AdHoc Issue
''   pad As String * 41                  '31Oct01 TH 42 - 1 from above field
   SupplierID As Long                  '**V93** needed for SQL
End Type
Type supplierstructold
   Code As String * 5
   contractaddress As String * 100
   supaddress As String * 100
   invaddress As String * 100
   conttelno As String * 14
   suptelno As String * 14
   invtelno As String * 14
   discountdesc As String * 70
   discountval As String * 9
   method As String * 1
   ordmessage As String * 50
   avleadtime As String * 4
   contfaxno As String * 14
   supfaxno As String * 14
   '24Oct96 EAC - match mod made in DOS 12Mar96 by ASC
   'invfaxno As String * 14
   'icode as string * 2
   invfaxno As String * 13                                   '@~@~!!
   pad1 As String * 3           '10Sep96 EAC was icode       '@~@~!!
   '---
   name As String * 15
   ptn As String * 1
   psis As String * 1
   fullname As String * 35     '21Mar93 CKJ Added
   discountbelow As String * 4 '  "
   discountabove As String * 4 '  "
   '27Aug96 EAC
   'pad As String * 95
   icode As String * 8                 '10Sep96 EAC
   CostCentre As String * 15           'could be subjective and/or objective code for links
   PrintDeliveryNote As String * 1     'Yes or No
   PrintPickTicket As String * 1       'Yes or No
   suppliertype As String * 1          'e.g. ward, store, external supplier
   OrderOutput As String * 1           'e.g. paper,fax,edi,internal, X25, modem
   ReceiveGoods As String * 1          'Yes or No
   '02Oct96 EAC
   TopupInterval As String * 2         'Number in days
   ATCSupplied As String * 1           'Yes or No
   pad2 As String * 4                  'WAS Cost code for ward
   topupdate As String * 8
   inuse As String * 1
   wardcode As String * 5              'Cost code for ward      '@~@~!! len 4 in translog
   onCost As String * 3                '19Apr00 JP On Cost as % charged to a ward.
   InPatientDirections As String * 1   '30Mar01 AE  "1" is on, anything else is false.
   'pad As String * 42                  '30Mar01 AE  43 - 1 for inpatient directions flag
   AdHocDelNote As String * 1          '31Oct01 TH Added new field to print delivery note on AdHoc Issue
   pad As String * 41                  '31Oct01 TH 42 - 1 from above field
   '---
End Type


Type V8DrugParameters
   Code As String * 8
   Description As String * 56
   inuse As String * 1
   deluserid As String * 3
   tradename As String * 30
   cost As String * 9
   contno As String * 10
   supcode As String * 5
   altsupcode As String * 29
   warcode2 As String * 6
   ledcode As String * 7
   SisCode As String * 7
   barcode As String * 13
   cyto As String * 1
   civas As String * 1
   formulary As String * 1
   bnf As String * 13
   ReconVol As Single
   ReconAbbr As String * 3
   Diluent1Abbr As String * 3
   Diluent2Abbr As String * 3
   MaxmgPerml As Single
   warcode As String * 6
   inscode As String * 6
   dircode As String * 6
   labelformat As String * 1
   expiryminutes As Long
   sisstock As String * 1
   ATC As String * 1
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
   extralabel As String * 3
   stocklvl As String * 9
   sislistprice As String * 9
   contprice As String * 9
   livestockctrl As String * 1
   leadtime As String * 3
   loccode As String * 3
   usagedamping As Single
   safetyfactor As Single
   indexed As String * 1
   recalcatperiodend As String * 1
   blank As String * 6           '18Jul97 CKJ datelastperiodend*6 stretched and moved below
   lossesgains As Single
   spare As String * 7           '14Mar95 CKJ -> 7 from 5 by removing worksheeetno chars 20Aug96 ASC
   dosesperissueunit As Single   '23Dec93 CKJ
   mlsperpack As Integer         'added for TPN 28Oct91 CKJ
   ordercycle As String * 2
   cyclelength As Integer
   lastreconcileprice As String * 9
   outstanding As Single         '20Mar93 ASC
   usethisperiod As Single       'ASC 9Apr93
   vatrate As String * 1         '24May93 ASC, 23Dec93 CKJ was Single
   DosingUnits As String * 5     '23Dec93 CKJ
   ATCCode As String * 8         ' was Prescribing code could be 4 I think
   UserMsg As String * 2
   MaxInfusionRate As Single     '<---CIVA added ASC 28Mar94
   MinmgPerml As Single          'ASC 28Mar94 removed dosing info to extend CIVAS
   InfusionTime As Single
   mgPerml As Single
   IVcontainer As String * 1
   DisplacementVolume As Single  '<---TO HERE
   PILnumber As Integer          '8Jun94 CKJ
   datelastperiodend As String * 8 '18Jul97 CKJ Moved from above and stretched to ddmmccyy
   MinDailyDose As Single
   MaxDailyDose  As Single
   MinDoseFrequency As Single
   MaxDoseFrequency As Single
   route As String * 20          '12Dec97 expanded - see below
   chemical As String * 50
   local As String * 7           '17Jul97 CKJ Added Local code
   extralocal As String * 3      'ASC/EAC 22Sep97
   DosesPerAdminUnit As Double   'ASC/EAC 22Sep97 for dose range checking '12Dec97 removed as it should have been single precision
   adminunit As String * 5       'ASC/EAC 22Sep97
   DPSform As String * 25        '12Dec97 CKJ Added to allow form of drug to be set via DPS
   storesdescription As String * 56
   storespack As String * 5
   teamworkbtn As Integer
   StrengthDesc As String * 12     '20Jul98 ASC added for HK only at present
   loccode2 As String * 3          '20Nov98 TH Added for enhanced stockcontrol
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
   stocktakestatus As String * 1
   laststocktakedate As String * 8
   laststocktaketime As String * 6
   pflag As String * 1
   issueWholePack As String * 1
   HasFormula As String * 1
   PIL2 As String * 10
   StripSize As String * 5
   pipcode As String * 7
   sparePIP As String * 5
   MasterPip As String * 7
   spareMasterPip As String * 5
   'Padding As String * 215          '           227 - (7 + 5)
   '28Sep12 Th Added
      'Padding As String * 215        '           227 - (7 + 5)
   PhysicalDescription As String * 35         '25Jan08 CKJ Added to hold 'Round white scored tablet ASC/500'
   'Padding As String * 180         '           215 - 35
   DDDValue   As String * 10       '06Aug09 TH Added for DDD enhancement (F0032563)
   DDDUnits   As String * 10       '   "
   UserField1   As String * 10     '   "
   UserField2   As String * 10     '   "
   UserField3   As String * 10     '   "
   HIPRoduct As String * 1         '06Aug09 TH Added for HIL enhancement (F0047569)
   Padding As String * 129         '           180 - 51

End Type             'Total length = 1024 chars

Type directstruct                                       '12Apr 97 CKJ copied here
   Code As String * 12 'top half same as label file
   route As String * 4
   EqualDose As Single
   EqualInterval As Single
   TimeUnits As String * 3
   RepeatInterval As Integer
   RepeatUnits As String * 3
   CourseLength As Integer
   CourseUnits As String * 3
   Abstime As String * 1
   Days As String * 1
   Dose(12) As Single
   'Time(12) as string * 4 Time reserved word in VBWIN
   Times(12) As String * 4

   DeletedBy As String * 5  'bottom half directions only
   ApprovedBy As String * 5
   RevisionNo As Integer
   deleted As String * 1
   location As String * 4   '20Jun95 CKJ was 5
   sparebyte As String * 1  '   "        added
   directs As String * 140
   PRN As String * 1     '13Nov94 ASC
   SortCode As String * 4              '04Mar99 CFY
   DSS As String * 1                   '     "      (0=Not DSS, 1=DSS Visible, 2=DSS Invisible)
   HidePrescriber As String * 1        '     "      (Y/N)
   ManualQtyEntry As String * 1        '09Aug99 SF added as a way of auto setting the manual qty entry flag
   StatDoseFlag As String * 1
   Padding As String * 41              '04Mar99 CFY Was 49 now 43, 09Aug99 SF was 43 now 42. 30Mar01 AE 42 to 41 and counting...
End Type

Global gTransport As PharmacyData.Transport
'Global gTransport As T9906PharmacyData000.Transport
Global g_SessionID As Long
Global gDispSite  As Long
Global d As DrugParameters
Global dispdata$
Dim iniHeapID%, fileHeapID%
Global TB As String
Global crlf As String
Global Const KEY_RETURN = &HD
Global Const KEY_INSERT = &H2D
Global Const KEY_DELETE = &H2E
Global Const KEY_TAB = &H9
Global Const KEY_ESCAPE = &H1B
Global rootpath$

Const OBJNAME As String = PROJECT & "TransactionConv."      '16Aug12 CKJ Added

Sub GetPointerSQL(FILE$, pointer&, Increment%)
'-----------------------------------------------------------------------------
'ASC 8 Nov 90       Reads pointer at beginning of RAM file
'
'
' If increment =  0   reads pointer                       (i.e. inc = FALSE)
'              = -1  reads pointer and adds one and saves (i.e. inc = TRUE )
'              =  1   reads pointer and takes one and saves
'              =  2   writes pointer
'              =  3   reads pointer locks it
'              =  4   unlocks pointer
'

'mods needed
' - take whole structure for record one then take pointer
' - use of chan = 0 will only work while only one file in the system needs locking
'-----------------------------------------------------------------------------
'18May05 TH Added write section (increment = 2) and removed original err raise on this section

''Dim p As pointertype, chan%, currentpoint&
Dim strParams As String
Dim lngPointer As Long
Dim intResult As Integer
Dim strPrefix As String
Dim intlastSlash As Integer
Dim strCategory As String
Dim strFile As String
Dim SiteID As Long
Dim procname$
Dim g_adoCn As ADODB.Connection
Dim gTransport As PharmacyData.Transport
'Dim gTransport  As T9906PharmacyData000.Transport
Dim ConnectionString As String
Dim g_SessionID As Long



'ConnectionString = "server=ascribesql\DEMO;database=v9-3-1_Tameside_Testing;uid=sys;password=sallyrulez!;provider=sqloledb;"
'ConnectionString = "server=ascribesql;database=v9-3-1_Testing;uid=sys;password=h4><0r!;provider=sqloledb;"
ConnectionString = frmConversion.txtConnect.Text
g_SessionID = 1664 '128

Set g_adoCn = New ADODB.Connection
g_adoCn.ConnectionString = ConnectionString
g_adoCn.Open

' gTransport.Connection.Open(
Set gTransport = New PharmacyData.Transport
'Set gTransport = New T9906PharmacyData000.Transport
Set gTransport.Connection = g_adoCn

   procname$ = "GetpointerSQL"

   Select Case Increment
      Case 3, 4
         Err.Raise 32767, procname$, "Warning: Program Halted. Corelib: GetPointer called with increment = 3 or 4"

      Case True
         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = 2      ''**!!** Check that this is a valid assumption
         End If
         'Convert the pathfile string to something useful for SQL

         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)

         lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerIncrement", strParams)

      Case 0
         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = 2     ''**!!** Check that this is a valid assumption
         End If

         'Convert the pathfile string to something useful for SQL
         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory)

         lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerRead", strParams)
         ' IF lngPointer is 0 then do Insert and put the new pointer !!
         'NO ! Now We Need to inform the user so they can put it in correctly. This is trapped below

      Case 2
         '18May05 TH Added as required in Manufacturing and removed original err raise on this section
         'Write to existing pointer record

         'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYL SEARCHSTRING (CATEGORY)
         If InStr(LCase(FILE$), "dispdata") > 0 Then
            strPrefix = "D"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "patdata") > 0 Then
            strPrefix = "P"
            'SiteID = 2
         ElseIf InStr(LCase(FILE$), "ascroot") > 0 Then
            strPrefix = "A"
            'SiteID = 2    ''**!!** Check that this is a valid assumption
         End If

         'Convert the pathfile string to something useful for SQL
         intResult = -1
         Do While intResult <> 0
            If intResult > 0 Then intlastSlash = intResult
            intResult = InStr(intlastSlash + 1, FILE$, "\", vbBinaryCompare)
         Loop
         strFile = Trim$(Mid$(FILE$, intlastSlash + 1))
         If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
         strCategory = strPrefix & "|" & strFile
         '-------------------------------------------------------------------------------
         '''Err.Raise 32767, procname$, "Warning: Corelib.GetPointer called with increment type 2" & crlf & "Not supported in this version. Inform Ascribe."
         strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                     gTransport.CreateInputParameterXML("Pointer", trnDataTypeint, 4, pointer&)

         lngPointer = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFilePointerWrite", strParams)
      End Select

   pointer& = lngPointer
''   currentpoint& = lngPointer

   If lngPointer < 0 Then
      'Here We Raise an error and inform the user that data is missing and needs to be rectified
      Err.Raise 32767, procname$, "Pointer record " & strCategory & " is missing from the database"
   End If

End Sub

Function ScalePrescribedUnits(ByRef d As DrugParameters, _
                              ByVal PrescribedUnits As String, _
                              ByRef NumericDose As Single, _
                              ByRef NumericDoseLow As Single, _
                              ByRef NumericDoseHigh As Single, _
                              ByRef message As String, _
                              ByRef strUnit As String _
                             ) As Boolean
'09May05 CKJ Given a prescription which is in PrescribedUnits, attempt to reconcile with
'            the IssueInits & DosingUnits of the chosen product
'
'             labelling may be in...     issue units                      dosing units
'prescribed units may be...      +----------------------------------------------------------------------
'  stores units (note 1)         ¦     * convfact (note 2)              * convfact * dosesperissueunit
'  related to stores units       ¦     * factor * convfact (note 3)     * factor * convfact * dosesperissueunit
'  issue units                   ¦       no ratio                       * dosesperissueunit
'  related to issue units        ¦     * factor                         * factor * dosesperissueunit
'  dosing units                  ¦     / dosesperissueunit                no ratio
'  related to dosing units       ¦     * factor / dosesperissueunit     * factor
'
'Note 1: The Stores unit is the quantity implied by 1 NSVcode-worth of the product
'        The description of this unit is d.storespack and is normally 'pack' (5 chars max)
'        The description is optional and may be blank
'Note 2: Convfact is the number of issue units in one Stores unit
'        e.g tablets in a bottle, mL in a bag, test stix in a pack
'Note 3: It is unlikely that a ratio will be needed between mass or volume units prescribed
'        and the mass or volume units in Stores unit, but for completeness it can be used
'** Stores units not yet implemented **
'
'IN:
'  d structure       product to reconcile against
'  PrescribedUnits   abbreviation eg mg microgram mL pack tab
'  NumericDose       Three numeric dose fields each of which will be scaled
'  NumericDoseLow    Pass 0 for any unused dose
'  NumericDoseHigh   "
'
'OUT:
'  NumericDose       Returned scaled or returned unchanged if success=true, zero if success=false
'  NumericDoseLow    "
'  NumericDoseHigh   "
'  Message           Short text description of resolution of the units or of the problem if success=false
'
'USES:
'  d.printformV, d.dosingUnits, d.dosesperissueunit & d.LabelInIssueUnits must be set
'  d.storespack is not a mandatory field, but is available will be used
'  SP pUnitConversion performs resolution within a unit family, eg g to mg

Dim success As Boolean
Dim factor As String
Dim prescaling As Boolean
Dim scalefactor As Variant

   success = True
   factor = ""
   prescaling = False
   message = ""
   
   If LCase$(PrescribedUnits) = LCase$(Trim$(d.PrintformV)) Then
      message = "Prescription in issue units, Dispensing in issue units"
      strUnit = LCase$(Trim$(d.PrintformV))
      If Not d.LabelInIssueUnits Then
         factor = "*"
         message = "Prescription in issue units, Dispensing in dosing units"
         strUnit = LCase$(Trim$(d.DosingUnits))
      End If

   ElseIf LCase$(PrescribedUnits) = LCase$(Trim$(d.DosingUnits)) Then
      message = "Prescription in dosing units, Dispensing in dosing units"
      strUnit = LCase$(Trim$(d.DosingUnits))
      If d.LabelInIssueUnits Then
         factor = "/"
         message = "Prescription in dosing units, Dispensing in issue units"
         strUnit = LCase$(Trim$(d.PrintformV))
      End If
   Else
      scalefactor = UnitConversion(PrescribedUnits, 1, Trim$(d.PrintformV))
      If Not IsNull(scalefactor) Then
         prescaling = True
         message = "Prescription in ratio of issue units, Dispensing in issue units"
         strUnit = LCase$(Trim$(d.PrintformV))
         If Not d.LabelInIssueUnits Then
            factor = "*"
            message = "Prescription in ratio of issue units, Dispensing in dosing units"
            strUnit = LCase$(Trim$(d.DosingUnits))
         End If
      Else
         scalefactor = UnitConversion(PrescribedUnits, 1, Trim$(d.DosingUnits))
         If Not IsNull(scalefactor) Then
            prescaling = True
            message = "Prescription in ratio of dosing units, Dispensing in dosing units"
            strUnit = LCase$(Trim$(d.DosingUnits))
            If d.LabelInIssueUnits Then
               factor = "/"
               message = "Prescription in ratio of dosing units, Dispensing in issue units"
               strUnit = LCase$(Trim$(d.PrintformV))
            End If
         Else
            message = "Prescribed units match neither the Dosing nor Issue units so a dose cannot be calculated"
            strUnit = ""
            success = False
         End If
      End If
   End If
   
   If success And Val(d.dosesperissueunit) = 0 Then
      Select Case factor
         Case "*", "/"
            success = False
            message = "Scaling of dose is required but 'doses per issue unit' is zero"
         End Select
   End If
   
   If success Then
      If prescaling Then
         NumericDose = dp!(NumericDose * CSng(scalefactor))
         NumericDoseLow = dp!(NumericDoseLow * CSng(scalefactor))
         NumericDoseHigh = dp!(NumericDoseHigh * CSng(scalefactor))
      End If
      
      Select Case factor
         Case "*"
            NumericDose = NumericDose * d.dosesperissueunit
            NumericDoseLow = NumericDoseLow * d.dosesperissueunit
            NumericDoseHigh = NumericDoseHigh * d.dosesperissueunit
         Case "/"
            NumericDose = dp!(NumericDose / d.dosesperissueunit)
            NumericDoseLow = dp!(NumericDoseLow / d.dosesperissueunit)
            NumericDoseHigh = dp!(NumericDoseHigh / d.dosesperissueunit)
         End Select
   Else
      NumericDose = 0
      NumericDoseLow = 0
      NumericDoseHigh = 0
   End If
   
   ScalePrescribedUnits = success

End Function
Function UnitConversion(ByVal SourceUnit As String, _
                        ByVal SourceValue As Single, _
                        ByVal DestinationUnit As String _
                       ) As Variant
'08Apr05 CKJ Calculate the ratio between two comparable units from the same family
'             UnitConversion("mg", 750, "g")  means convert 750mg to grams and returns 0.75
'            Returns NULL if a ratio cannot be determined eg UnitConversion("kg", 1, "cm")
  
Dim strParameters As String
Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "UnitConversion"
Const OBJNAME = "UnitConversion"

   On Error GoTo ErrorHandler
   UnitConversion = Null
   
   strParameters = gTransport.CreateInputParameterXML("SourceUnit", trnDataTypeChar, 50, SourceUnit) _
                 & gTransport.CreateInputParameterXML("SourceValue", trnDataTypeFloat, 4, SourceValue) _
                 & gTransport.CreateInputParameterXML("DestinationUnit", trnDataTypeChar, 50, DestinationUnit)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pUnitConversion", strParameters)
   UnitConversion = rs.Fields("DestinationValue")
  
Cleanup:
   On Error Resume Next
   Set rs = Nothing
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
      
Exit Function

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
 
End Function

Function dp!(Number!)
'-----------------------------------------------------------------------------
' Decimal Places:
'
' This function takes a single precision number (positive or negative
' including exponential notation) and returns the number to one less digit
' of precision in the decimals, by rounding the last digit. This only occurs
' if the number has 7 or more significant figures.
' 12Sep95 CKJ Added handling of small negative exponentials
'   1.234567  =>  1.23457
'  -1.234567  => -1.23457
'   1.23456   =>  1.23456      (unchanged)
'   1.23E-07  =>  0
'   1.23E-06  =>  1.23E-06
'   1.23E-04  =>  .000123
'-----------------------------------------------------------------------------
Dim X!, vals$, expon%, mantissa$, mantnodp$, expval%, decpt%, Last%, adj$, round$

   X! = Abs(Number!)
   vals$ = LTrim$(Str$(X!))
   expon = InStr(vals$, "D")
   If expon = 0 Then expon = InStr(vals$, "E")

   If expon Then
         mantissa$ = Left$(vals$, expon - 1)                   ' 1.234
         mantnodp$ = Left$(mantissa$, 1) & Mid$(mantissa$, 3)  ' 1234
         expval = Val(Mid$(vals$, expon + 1))          ' 1.234567E-07  =>  -7
         Select Case expval
            Case Is <= -7
               dp! = 0
            Case -6 To -1        ' .0000012 to .1234567     12Sep95 CKJ Added
               dp! = Sgn(Number!) * Val(Left$("." & String$(expval * -1 - 1, "0") & mantnodp$, 8))
           'CASE 1 TO 8          ' 12.3456789 to 123456789
           '   dp! = SGN(number!) * VAL(LEFT$(mantnodp$, expval + 1) + "." + MID$(mantnodp$, expval + 2))
            Case Else
               dp! = Number!
            End Select
      Else

         decpt = InStr(vals$, ".")
         Last = Val(Right$(vals$, 1))
         If decpt <> 0 And Len(vals$) >= 9 Then                   ' 765.12345
               If Last >= 5 Then  ' round up
                     adj$ = LTrim$(Str$(10 - Last))
                     round$ = "."
                  Else            ' round down
                     adj$ = LTrim$(Str$(Last))
                     round$ = "-."
                  End If
               round$ = round$ & String$(Len(vals$) - decpt - 1, "0") & adj$ '    .00005
               dp! = Sgn(Number!) * (Val(vals$) + Val(round$))     ' 765.1235
            Else
               dp! = Number!
            End If
      End If

End Function
Function GetField(fld As ADODB.field) As Variant
' 2Apr96 CKJ Written
'            Avoids 'Invalid use of Null' problems by assigning
'            zero, "" or date'0' as appropriate.
'14Oct96 CKJ Null date now returns 0# not 31-12-1899
'23aug04 ckj rewritten for adodb
'
'ADODB.DataTypeEnum
' adDate = 7
' adDBDate = 133
' adDBTime = 134
' adDBTimeStamp = 135
' adCurrency = 6
' adBSTR = 8
' adChar = 129
' adWChar = 130
' adVarChar = 200
' adLongVarChar = 201
' adVarWChar = 202
' adLongVarWChar = 203
' adArray = 8192

'  Boolean
'  Byte
'  Integer
'  Long
'  currency
'  single
'  double
'  text
'  longbinary
'  memo

   If IsNull(fld) Then
         Select Case fld.Type
            Case 7, 133, 134:             GetField = 0#
            Case 8, 129, 130, 200 To 203: GetField = ""
            Case Else:                    GetField = 0
            End Select
      Else
         GetField = fld
      End If

End Function

Function RtrimGetField(fld As ADODB.field) As Variant
'23aug04 CKJ based on GetField, but Rtrims the text and memo types

   If IsNull(fld) Then
         Select Case fld.Type
            Case 7, 133, 134:             RtrimGetField = 0#  'Format$(0, "dd-mm-yyyy")
            Case 8, 129, 130, 200 To 203: RtrimGetField = ""
            Case Else:                    RtrimGetField = 0
            End Select
      Else
         Select Case fld.Type
            Case 8, 129, 130, 200 To 203: RtrimGetField = RTrim$(fld)
            Case Else:                    RtrimGetField = fld
            End Select
      End If

End Function
Function TxtD(pathfile$, Section$, default$, entry$, found As Integer) As String
'Example:
'  File        DFHL.044          DFHL.LNG
'  Section     <none>            [044]
'  Entry       AskSupport=Contact ASC Support
'              AskSupport="Contact ASC Support  "
'              AskSupport="Contact ASC Support"   'max 70
'              AskSupport="Contact ASC Support"   ;max 70
'              (NB No comments allowed unless quotes are used)
'              (and no trailing spaces unless quotes are used)
'  Comment     ' Comment line
'              ; Comment line

' Filenames will be searched in the following order
'  if no filename   \ASCROOT\ASCRIBE.044    Section <none>
'                   \ASCROOT\ASCRIBE.LNG    Section [044]
'  exact match of   <pathfile>
'  if no ext given  \ASCROOT\<pathfile>.044 given Country=044 in config.sys
'                                           or Set Country=044 in autoexec.bat
'                   \ASCROOT\<pathfile>.LNG Section [044]
'
' If file/section/entry not found returns error msg:
'     "TEXT <section> <entry> MISSING FROM <file>"
'
'
' 9Jun94 CKJ Uses GetCountry
'10Jun94 CKJ Arrays files$(x,1) and srch$(y,1) cache filenames & entries
' 9Nov94 CKJ Order of file search changed. NOT perfect logic
'            - but will give 1st time hit in practice when given DQQW;
'            finds \ASCROOT\DQQW.044 or equivalent
'19Dec94 CKJ If Default is chr$(26), EOF, then End if not found in file.
'            - chosen as it would not occur inside a text file.
'            Cacheing now cleared if default disk is changed
'20Dec94 CKJ Also returns found = T/F
'19Jan95 CKJ Added debug option: command line /TXTDEBUG for missing lines
'25Jan95 CKJ Now stores new finds in buffer
'26Jan95 CKJ Simplified use of default to correct bug when found = default
'17Feb95 CKJ Preserve errnum across the call
'04Jun97 EAC moved to module level to allow flushing of cache
'12Mar99 CKJ Added Tamper check on INI files. No message on files which have no validation though
'29Oct99 CKJ Divert call to TxtH() which uses the Heap to manage caching
'14Nov00 CKJ Written style lookup and cache, no divert unless command line includes /OLDINICACHE
'            Cache whole file without using the API call
'            This is designed to improve reliability & reduce network traffic
'            Once a new file has been encountered, read the entire file in one pass
'            Read it in chunks of 10-30K, reducing the need for multiple tiny network packets
'            Cache misses on the file cache are still recorded, but not for the item cache
'            because the whole file is held and therefore a heap miss is also a cache miss.
'
'            Filename given                  Filname to look for                Action
'            ------------------------------  ---------------------------------  -----------
'            \apath\inifile.ext              x:\apath\inifile.ext               Add current drive
'            d:\apath\inifile.ext            d:\apath\inifile.ext               None
'            \\svr\share\apath\inifile.ext   \\svr\share\apath\inifile.ext      None
'
'            inifile                         x:\ascroot\inifile.ccc             Try local country in current ascroot,
'                                            x:\ascroot\inifile.044             then try country 044 in current ascroot
'
'            ccc     is the country number in regional settings
'            x:      is the default drive
'
'            Note that there are two subtle changes in behaviour:
'            If two country specific files exist, and the item is not found in the first one, then lookup is now performed
'             on the second file as well. Previously the routine would stop after the first file.
'            Use of the chr(26) flag to force ending of the program is not available execpt from the siteinfo() procedure.
'
'24Nov00 CKJ Renamed TxtH() as TxtHeap(). See procedure for details.
'-----------------------------------------------------------------------------
Dim sBuffer As String                                                          'String buffer
Dim sFile1 As String                                                           'First filename to look for
Dim sFile2 As String                                                           'Second filename to look for
Dim country As Integer
Dim rootpath$

   found = False                                                               'Not Found' until proven otherwise
   sBuffer = default$                                                          'preset default answer
   sFile1$ = UCase$(pathfile$)
   sFile2$ = ""
   
   If InStr(Right$(pathfile$, 4), ".") = 0 Then                                'no extension, eg 'DFHL'
        '''GetCountry country
        country = 44
        If country <> 44 Then sFile2$ = frmConversion.txtDrive & ":\ascroot\" & sFile1$ & ".044"    'not UK, 2nd file is X:\ascroot\file.044
        sFile1$ = rootpath$ & "\" & sFile1$ & "." & Format$(country, "000")   'may not be UK, try X:\ascroot\file.xxx
      End If
   
   If Left$(sFile1$, 2) <> "\\" And Mid$(sFile1$, 2, 1) <> ":" Then sFile1$ = Left$(CurDir$, 2) & sFile1$
   sBuffer = IniCache(sFile1$, Section$, default$, entry$, found)

   If Not found And Len(sFile2$) > 0 Then                                       'didn't find it, and there's a second filename
        If Left$(sFile2$, 2) <> "\\" And Mid$(sFile2$, 2, 1) <> ":" Then sFile2$ = Left$(CurDir$, 2) & sFile2$
        sBuffer = IniCache(sFile2$, Section$, default$, entry$, found)
      End If

   TxtD$ = sBuffer

End Function
Sub GetCountry(country%)
'14Nov00 CKJ Added system-wide setting for country
'            Previously this had to be set on each PC either as an environment variable in Autoexec.bat or similar
'            eg SET Country="061"
'            or as the regional settings in control panel
'            Now, add the following line to Siteinfo.ini default section
'            []
'            Country="061"
'            This is tested between the original two, so the net effect is as follows
'            Use country defined in Autoexec.bat if present
'             otherwise use country defined in Siteinfo.ini if present
'             otherwise use country in regional settings
'            If all else fails then use 044
'            Note: GetProfileString is not used for siteinfo.ini since it performs badly when the network is inadequate.
'            However it is used for the regional settings since this is always on the local machine and is mapped to a
'            registry entry on NT without changing the call.
'            The result of the test is also held as a static, preventing the need to check every time.

Static iCountry As Integer

Dim lpreturnstring As String, iResult As Integer
Dim iChan As Integer, sFilename As String
Dim sText As String, iPosn As Integer
Dim strParams As String
Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "GetCountry"

   On Error GoTo ErrorHandler

   If iCountry = 0 Then
      iCountry = Val(Environ$("COUNTRY"))
      
''         If iCountry = 0 Then                                            'read country=xx in siteinfo.ini
''            sFilename = "\DISPDATA." & Format$(Val(g_command), "000") & "\siteinfo.ini"
''            If fileexists(sFilename) Then
''                  iChan = FreeFile
''                  Open sFilename For Binary As #iChan
''                  sText = Space$(LOF(iChan))
''                  Get #iChan, , sText                                 'read whole file as one string
''                  Close iChan
''                  iPosn = InStr(LCase$(sText), crlf & "country")      'look for <CrLf>Country = ...
''                  If iPosn Then                                       'found it
''                        sText = LTrim$(Mid$(sText, iPosn + 9))        'trim to leave "= ..."
''                        If Left$(sText, 1) = "=" Then                 'remove the equals and subsequent spaces
''                              sText = LTrim$(Mid$(sText, 2))          'now is 061... or "061"...
''                              If Left$(sText, 1) = Chr$(34) Then      'remove the " character if present
''                                    sText = LTrim$(Mid$(sText, 2))
''                                 End If
''                              iCountry = Val(Left$(sText, 3))         'should ignore any trailing characters including "
''                           End If
''                     End If
''                End If
''         End If
      
   If iCountry = 0 Then
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, "D|Siteinfo") & _
                  gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 255, "") & _
                  gTransport.CreateInputParameterXML("Key", trnDataTypeVarChar, 255, "Country")
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWConfigurationSelectValue", strParams)
      If Not rs Is Nothing Then
         If rs.State = adStateOpen Then
            If rs.RecordCount <> 0 Then
               lpreturnstring = RtrimGetField(rs!Value)
               If Left$(lpreturnstring, 1) = Chr$(34) Then lpreturnstring = Mid$(lpreturnstring, 2)
               If Right$(lpreturnstring, 1) = Chr$(34) Then lpreturnstring = Left$(lpreturnstring, Len(lpreturnstring) - 1)
               iCountry = Val(lpreturnstring)
            End If
            rs.Close
         End If
      End If
   End If
      
'09May05 CKJ Win.ini deprecated
'»         If iCountry = 0 Then
'»               lpreturnstring = Space$(512)
'»               iResult = GetProfileString("intl", "iCountry", "FAILED", lpreturnstring, 512)
'»               lpreturnstring = Trim$(asciiz$(lpreturnstring))
'»               iCountry = Val(lpreturnstring) '44
               If iCountry = 0 Then iCountry = 44   '19Oct04 TH Reinstated
'»            End If
   End If

Cleanup:
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   
   country = iCountry
   If lErrNo Then
      Err.Raise lErrNo, "GC" & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub
Function IniCache(i_Pathfile As String, i_Section As String, i_Default As String, i_Entry As String, io_Found As Integer) As String

'            Read contents of file and item caches, return result having cached file if necessary

Dim sItemSearch As String
Dim sBuffer As String                                                       'String buffer
Dim sSection As String                                                      'Ini file [section] in scope
Dim sPathFile As String
Dim bFileInCache As Integer
Dim bDone As Integer
Dim rsIniSetting    As ADODB.Recordset
Dim strParameters As String
Dim sSetting As String
Dim sNewEntry As String
Dim sValue As String
Dim strPrefix As String
Dim strCategory As String
Dim strSiteID As String
Dim intResult As Integer
Dim intlastSlash As Integer
Dim strFile As String

   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0

   io_Found = False                                                         'assume not found as default
   sBuffer = i_Default                                                      'and prefill the buffer with supplied string
   sSection = UCase$(Trim$(i_Section))
   sPathFile = UCase$(Trim$(i_Pathfile))
   strSiteID = Format$(gDispSite)           '!!** Needs changing
   
   'PUT THE FOLLOWING INTO A FUNCTION RETURNING A SQL STYLE SEARCHSTRING (CATEGORY)
   If InStr(LCase(sPathFile), "dispdata") > 0 Then
      strPrefix = "D"
   ElseIf InStr(LCase(sPathFile), "patdata") > 0 Then
      strPrefix = "P"
   ElseIf InStr(LCase(sPathFile), "ascroot") > 0 Then
      strPrefix = "A"
   End If
   'Convert the pathfile string to something useful for SQL
   
   intResult = -1
   Do While intResult <> 0
      If intResult > 0 Then intlastSlash = intResult
      intResult = InStr(intlastSlash + 1, i_Pathfile, "\", vbBinaryCompare)
   Loop
   strFile = Trim$(Mid$(i_Pathfile, intlastSlash + 1))
   If InStr(LCase(strFile), ".ini") > 0 Then strFile = Left$(strFile, Len(strFile) - 4)
   strCategory = strPrefix & "|" & strFile
   '-------------------------------------------------------------------------------
   
   'i_Pathfile
   sItemSearch = strSiteID & "|" & strCategory & "|" & sSection & "|" & UCase$(Trim$(i_Entry))  'try file+item in item cache
          
   Do
      bDone = True                                                          'assume single pass unless otherwise needed
      Heap 11, iniHeapID, sItemSearch, sBuffer, io_Found                    'check the item cache for the item
      If io_Found Then                                                      'entry found in cache
            'bDone, sBuffer and io_Found are already set correctly
      Else                                                                  'entry not in cache, so is the section cached?
         Heap 11, fileHeapID, strSiteID & "|" & strPrefix & "|" & strFile & "|" & sSection, "", bFileInCache
         If bFileInCache Then                                               'entry found in cache
               'note that the filen|section is cached but the file itself may or may not exist on disk
               'filename is in the file cache, item not in file cache => item not present
               'bDone, sBuffer and io_Found are already set correctly
            Else
               'Debug.Print strCategory, sSection
               AddSectionToCacheSQL strCategory, sSection                   'sPathFile
               bDone = False
            End If
      End If
   Loop Until bDone

   IniCache = sBuffer
            
End Function
Sub AddSectionToCacheSQL(ByVal strCategory As String, ByVal strSection As String)

Dim rsConfiguration As ADODB.Recordset
Dim strParameters As String, str1 As String, str2 As String
Dim strValue As String

   'errnumcopy = errnum
   'errnum = False
   
   If iniHeapID = 0 Then Heap 1, iniHeapID, "Configuration Settings - item cache", "", 0
   If fileHeapID = 0 Then Heap 1, fileHeapID, "Configuration Settings - file cache", "", 0
   If Len(TB) = 0 Then
      ''MsgBox "Design Fault: Inform ASC that ReadSiteInfo was not called when program started", MB_ICONSTOP, "ASCribe - System Error"
   End If
     
   Heap 10, fileHeapID, Format$(gDispSite) & "|" & strCategory & "|" & strSection, "1", 0  'Add Section to ini heap
   
   'Now get all the possible keys
   strParameters = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Category", trnDataTypeVarChar, 255, strCategory) & _
                   gTransport.CreateInputParameterXML("Section", trnDataTypeVarChar, 255, strSection)
   Set rsConfiguration = gTransport.ExecuteSelectSP(g_SessionID, "pWConfigurationSelectSection", strParameters)
   If Not rsConfiguration.EOF Then
   'FILL ITEM CACHE HERE
      rsConfiguration.MoveFirst
      Do While Not rsConfiguration.EOF
         str1 = Format$(gDispSite) & "|" & strCategory & "|" & strSection & "|" & Trim$(GetField(rsConfiguration!key))
         strValue = GetField(rsConfiguration!Value)
         If Len(strValue) > 2 Then
            str2 = Mid$(Trim$(strValue), 2, Len(Trim$(strValue)) - 2)
         Else
            str2 = ""
         End If
         Heap 10, iniHeapID, str1, str2, 0
         rsConfiguration.MoveNext
      Loop
   End If
   rsConfiguration.Close
   Set rsConfiguration = Nothing
   
   'errnum = errnumcopy

End Sub
Sub Heap(Action%, HeapID%, entry$, Value$, success%)
'------------------------------------------------------------------------------------------------
'13Jan98 CKJ Heap Manager written
'            This uses frmHeap which has a single sorted listbox. A new listbox is allocated
'            for each heap, and as heaps are created & destroyed this becomes a sparse array.
'            Each line in the array holds 'Entry & Tab & Value' and is searched using the
'            SendMessage API with LB_FINDSTRING
'
'            Limits are 255 heaps, 32K entries, 32K per entry; though not at the same time <g>
'            Please initialise once and remember the HeapID handle.
'            Pass the handle with every subsequent action, and destroy the heap afterwards.
'            The routine is able to support multiple heaps, and these do not interact with
'            each other, beyond the effects on system resources.
'            Think of it as a fast memory based INI file and you won't go far wrong.
'             allocate a HeapID for each file or section
'             then store entry=value for as many items as needed
'            As with INI files, the search using Entry is case insensitive,
'            but unlike INI files, leading and trailing spaces are kept and used.
'            All ASCII characters can be used in Value.
'            Duplicate entries cannot be created, as the first entry simply gets updated.
'            Remember to check the value of Success - it won't always be TRUE
'Action
'  0  Destroy all heaps. Returns success=T/F. HeapID, Entry and Value are ignored.
'      Caution - use only as program ends as this destroys the contexts for all heaps.
'  1  Initialise a heap. Returns success=T/F and HeapID=0 if failed, >0 if allocated.
'      Entry can optionally be set to a short description which is shown on the debug screen.
'      Value is ignored, and both Entry and Value are returned unchanged
'  2  Destroy a heap. Requires HeapID. Returns success=T/F and sets HeapID=0 if successful.
'      Entry & value are ignored and are returned unchanged
' 10  Write to a heap. Requires HeapID, entry and value. Returns success=T/F
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab.
'      Value can be "" or up to 32K long.
' 11  Read from a heap. Requires HeapID & entry. Returns value and success=T/F
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab
'      If entry is not found then success=false and value is unchanged,
'      hence value can be given a default and this will be returned.
' 12  Remove from a heap.  Requires HeapID & entry. Returns success=T/F. Value is ignored
'      Entry <> "" and must not contain Chr$(0), Chr$(1) or Tab
'      If entry is not found then success=false
' 13  Read next item from heap. Given entry, it finds and returns the next item after entry.
'      Requires HeapID & entry. Returns entry, value and success=T/F
'      Entry must not contain Chr$(0), Chr$(1) or Tab
'      If entry is "" then the first item on the heap is returned
'      If entry is found then the next item after it is returned, except when this
'      is the last item in the heap, it sets success=false, entry and value are unchanged.
'      If entry is not found then success=false, both entry and value are unchanged.
' 14  Read last item from a heap.
'      Requires HeapID. Returns entry, value and success T/F.
'      If heap is empty then success is False, both entry & value are unchanged.
' 20  Returns number of active heaps in the HeapID parameter,
'      return '|' separated list of heap IDs in Value$
'      and '|' separated list of Heap descriptions in Entry$
'      success% ignored and unchanged
' 21  Returns frmHeap.hWnd or 0 if no heaps initialised in the HeapID parameter.
'      Entry$, Value$, success% all ignored
'100  Display Heap for debug. Requires HeapID. Returns Success=T/F. Entry & value are ignored.
'
'24Jan98 CKJ Added actions 20 & 21
'29Apr98 CKJ Found that each entry accepts up to 32K of data, but keeps first 1K only.
'            Amended to allow linked list storage, using suffix to the item key.
'            This is transparent in use and does not affect existing code.
'            Limit now of ~16000 entries of 1K, more with smaller data items.
'16Jul98 CKJ Corrected bug in action 11 - items not found in heap were returned as blank
'14Sep98 CKJ Action 22 written; return hwnd of individual list box
'            Binary search written to replace LB_FINDSTRING which appears to do a brute-force
'            sequential search. The binary search is over twice as fast on a list of ~500 items.
'15Sep98 CKJ Added Actions 23 & 24 set redraw off/on, and replaced Additem with LB_ADDSTRING
'25Sep98 CKJ Removed actions 22, 23, 24: list().hwnd should remain encapsulated, and inhibiting
'            redraw does not improve speed.
'            Binary search rewritten to handle all access to the now unsorted lists, since the
'            sort order is not in ASCII order. Internal separator char changed from ascii 127->1
'19Jul99 AE  Action 11: moved "success = true" to make procedure work as described
'28Oct99 CKJ Corrected action 1 - do not blank heap name.
'            Extended action 20 - return '|' separated list of heap IDs in Value$
'            and '|' separated list of Heap descriptions in Entry$
'22Nov00 CKJ added heap size calculation, displayed on debug window caption
'30Apr02 CKJ Added action 13 which provides a findfirst/findnext capability. Returns next item
'            after the entry supplied, or the very first item if entry="". Repeat while success=T
'19May04 CKJ Added action 14 which returns the last code and entry from a heap
'09May05 CKJ Multiselect & copy added in debug page
'
'Mods wanted:
'  make the routine fully recursive, and keep one heap with details of all current heaps
'  add an array of items in one go
'  search on partial key and return all matching items
'  search on partial key and delete all matching items
'/ shutdown option, to destroy all heaps and unload frmHeap
'  full error reporting, with numerical & text error codes
'  store heaps to disk & reload again
'  need a way of detecting that the form has been unloaded by some other module
'   (and maybe cancelling the unload request)
'------------------------------------------------------------------------------------------------
'HeapID numbers are in the range 1 to HighTide, with NumInstances heaps allocated and active.
Static NumInstances%, HighTide%
Dim i%, ptr%, key$, sep$, tmp$, done%, top%, bot%, sch%, lenkey%, InsertPtr%
Dim lHeapSize As Long

   success = False
   sep$ = Chr$(1)                                   '25Sep98 CKJ was chr(127)
   On Error GoTo HeapErr
   Select Case Action                               'don't mess with the design time object
      Case 2, 10, 11, 12, 13, 14, 22, 100
         If HeapID = 0 Then Exit Sub
      End Select
   
   Select Case Action
      Case 0                   'Destroy all heaps
         On Error Resume Next                       'heap may not be in use
         For i = 1 To HighTide
            frmHeap.lstHeap(i).Clear
            Unload frmHeap.lstHeap(i)
         Next
         On Error GoTo HeapErr
         HighTide = 0
         NumInstances = 0
         Unload frmHeap
         Set frmHeap = Nothing                      '24Jan98 CKJ added
         success = True
      
      Case 1                   'Create a heap
         HeapID = 0
         If NumInstances = 0 Then Load frmHeap
         NumInstances = NumInstances + 1
         On Error Resume Next
         For i = 1 To HighTide
            'frmHeap.lstHeap(i).Tag = ""            'find a spare (deallocated) heap
            tmp$ = frmHeap.lstHeap(i).Tag           'find a spare (deallocated) heap '28Oct99 CKJ Corrected
            If Err Then Exit For
         Next
         On Error GoTo HeapErr                      'i now holds a free ID, or is HighTide+1
         If i > HighTide Then HighTide = i
         Load frmHeap.lstHeap(i)
         frmHeap.lstHeap(i).Tag = entry$
         HeapID = i
         success = True
      
      Case 2                   'Destroy a heap
         frmHeap.lstHeap(HeapID).Clear
         Unload frmHeap.lstHeap(HeapID)
         If HeapID = HighTide Then HighTide = HighTide - 1
         'Note that HighTide may still be artificially high; imagine heaps 1-4 allocated,
         'then destroy 2,3,4 in that order. HighTide now 3, but could be set to 1. Not
         'worth scanning downwards for first allocated list though. Just check if it could
         'be zeroed.
         NumInstances = NumInstances - 1
         If NumInstances = 0 Then
               HighTide = 0
               Unload frmHeap
               Set frmHeap = Nothing                '24Jan98 CKJ added
            End If
         HeapID = 0
         success = True
      
      Case 10                  'Write to a heap
         If entry$ <> "" And InStr(entry$, TB) = 0 And InStr(entry$, sep$) = 0 Then
               done = False
               key$ = UCase$(entry$) & sep$ & "0" & TB               '15Sep98 CKJ ucase added
               
               GoSub BinarySearchHeap
               
               If frmHeap.lstHeap(HeapID).ListIndex > -1 Then              'found it
                     ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                     If Len(key$ & Value$) <= 1024 And ptr = 0 Then   'new & old items fit in one block
                           frmHeap.lstHeap(HeapID).List(frmHeap.lstHeap(HeapID).ListIndex) = key$ & Value$
                           done = True
                           success = True
                        Else
                           Heap 12, HeapID, entry$, "", success            'remove old item
                           If Not success Then Error 32767                 'quit
                           success = False                                 'reset ready for the add
                        End If
                  End If

               If Not done Then                                            'add it
                     ptr = 0
                     tmp$ = Value$
                     Do                                                    'iteratively add 1K blocks until done
                        key$ = UCase$(entry$) & sep$ & Format$(ptr) & TB   '15Sep98 CKJ ucase added
                        GoSub BinarySearchHeap                             'InsertPtr now set
                        frmHeap.lstHeap(HeapID).AddItem Left$(key$ & tmp$, 1024), InsertPtr

                        If Len(key$ & tmp$) > 1024 Then
                              ptr = ptr + 1                                'allocate next block
                              tmp$ = Mid$(tmp$, 1024 - Len(key$) + 1)      'keep remainder
                           Else
                              ptr = 0                                      'finished
                           End If
                        frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).NewIndex) = ptr
                     Loop Until ptr = 0
                     success = True
                  End If
            End If
      
      Case 11                  'Read a heap
         If entry$ <> "" And InStr(entry$, TB) = 0 And InStr(entry$, sep$) = 0 Then
               ptr = 0
               'Value$ = ""    '16Jul98 CKJ don't blank it until we've found its replacement
               Do
                  key$ = UCase$(entry$) & sep$ & Format$(ptr) & TB      '15Sep98 CKJ ucase added
               
                  GoSub BinarySearchHeap
               
                  If frmHeap.lstHeap(HeapID).ListIndex > -1 Then     'found it
                        If ptr = 0 Then Value$ = ""                  '16Jul98 CKJ first part of the retrieval
                        ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                        Value$ = Value$ & Mid$(frmHeap.lstHeap(HeapID).Text, Len(key$) + 1)
                        success = True                                     '19Jul99 AE added
                     ElseIf ptr > 0 Then                             'failed to find it, but should have done
                        success = False                                    '19Jul99 AE added
                        'popmessagecr "!", "Heap Manager - error reading linked list: " & Str$(HeapID) & " " & entry$ & Str$(ptr)
                        Error 32766
                     End If
               Loop While ptr > 0
              ' success = True                                '19Jul99 AE AE moved into if statement above
            End If
      
      Case 12                  'Remove from a heap
         If entry$ <> "" And InStr(entry$, Null) = 0 And InStr(entry$, TB) = 0 And InStr(entry$, sep$) = 0 Then
               ptr = 0
               Do
                  key$ = UCase$(entry$) & sep$ & Format$(ptr) & TB      '15Sep98 CKJ ucase added
               
                  GoSub BinarySearchHeap

                  If frmHeap.lstHeap(HeapID).ListIndex > -1 Then     'found it
                        ptr = frmHeap.lstHeap(HeapID).ItemData(frmHeap.lstHeap(HeapID).ListIndex)
                        frmHeap.lstHeap(HeapID).RemoveItem frmHeap.lstHeap(HeapID).ListIndex
                     ElseIf ptr > 0 Then                             'failed to find it, but should have done
                        'popmessagecr "!", "Heap Manager - error removing linked item: " & Str$(HeapID) & " " & entry$ & Str$(ptr)
                        Error 32767
                     End If
               Loop While ptr > 0
               success = True
            End If
      
      ' 13  Read next item from heap. Given entry, it finds and returns the next item after entry.
      '      Requires HeapID & entry. Returns entry, value and success=T/F
      '      Entry must not contain Chr$(0), Chr$(1) or Tab
      '      If entry is "" then the first item on the heap is returned
      '      If entry is found then the next item after it is returned, except when this
      '      is the last item in the heap, it sets success=false, entry and value are unchanged.
      '      If entry is not found then success=false, both entry and value are unchanged.

      Case 13                  'Read next item from a heap
         If InStr(entry$, Null) = 0 And InStr(entry$, TB) = 0 And InStr(entry$, sep$) = 0 Then
               If entry$ = "" Then                                            'read first item on heap
                     If frmHeap.lstHeap(HeapID).ListCount > 0 Then            'heap has at least one item
                           entry$ = frmHeap.lstHeap(HeapID).List(0)           'retrieve whole of the first line
                           entry$ = Left$(entry$, InStr(entry$, sep$) - 1)    'and retain just the key part
                           Heap 11, HeapID, entry$, Value$, success           'and find using recursive call
                        End If
                  Else                                                        'find subsequent item after given entry
                     key$ = UCase$(entry$) & sep$ & Format$(0) & TB           'start with the given entry
                     GoSub BinarySearchHeap
                     Do While frmHeap.lstHeap(HeapID).ListIndex > -1
                        If Left$(frmHeap.lstHeap(HeapID).Text, Len(entry$) + 1) = UCase$(entry$) & sep$ Then
                              'still reading elements belonging to the given entry, so step past these
                              If frmHeap.lstHeap(HeapID).ListIndex < frmHeap.lstHeap(HeapID).ListCount - 1 Then
                                    frmHeap.lstHeap(HeapID).ListIndex = frmHeap.lstHeap(HeapID).ListIndex + 1
                                 Else
                                    frmHeap.lstHeap(HeapID).ListIndex = -1    'end of heap reached
                                 End If
                           Else                                               'not end of heap, and next item has been found
                              entry$ = frmHeap.lstHeap(HeapID).Text           'retrieve whole of the line
                              entry$ = Left$(entry$, InStr(entry$, sep$) - 1) 'and retain just the key part
                              Heap 11, HeapID, entry$, Value$, success        'and find using recursive call
                              Exit Do
                           End If
                     Loop
                  End If
            End If

      Case 14                  'return last item from a heap
         If frmHeap.lstHeap(HeapID).ListCount Then
               key$ = frmHeap.lstHeap(HeapID).List(frmHeap.lstHeap(HeapID).ListCount - 1)  'read last line, may be end of linked list
               key$ = Left$(key$, InStr(key$, sep$) - 1)                      'and retain just the key part
               Heap 11, HeapID, key$, Value$, success                         'and find using recursive call
               If success Then entry$ = key$                                  'return the key for this item
            End If

      Case 20                  'return number of active heaps
         HeapID = NumInstances
         Value$ = ""                                '28Oct99 CKJ Added block to fill Value with '|' separated list of heaps
         entry$ = ""                                '            and fill Entry$ with Heap descriptions
         On Error Resume Next
         For i = 1 To HighTide
            Err = 0
            tmp$ = frmHeap.lstHeap(i).Tag           'try using an lstHeap - it may not exist
            If Err = 0 Then
                  If Len(Value$) > 0 Then Value$ = Value$ & "|"
                  Value$ = Value$ & Str$(i)
                  If Len(entry$) > 0 Then entry$ = entry$ & "|"
                  entry$ = entry$ & frmHeap.lstHeap(i).Tag
               End If
         Next
         On Error GoTo HeapErr
      
      Case 21                  'return frmHeap.hWnd
         If NumInstances > 0 Then
               HeapID = frmHeap.hWnd
            Else
               HeapID = 0
            End If

      Case 100                 'display heap for debugging
'''         With frmHeap.lstHeap(HeapID)
'''            .Visible = True
'''            lHeapSize = 0                                                           '22Nov00 CKJ added heap size calculation
'''            For i = 0 To .ListCount - 1
'''               lHeapSize = lHeapSize + Len(.List(i))
'''            Next
'''            lHeapSize = (lHeapSize + 1023) \ 1024                                   '   "        round up to next whole Kb
'''            frmHeap.Caption = "Debug Heap" & Str$(HeapID) & " " & .Tag & ";" & Str$(.ListCount) & " entries " & Format$(lHeapSize) & "Kb (" & Format$(NumInstances) & " active heaps)"
'''         End With
'''
'''         ReDim TabStops(1) As Long
'''         TabStops(1) = 4 * 50
'''         ListBoxTextBoxSetTabs frmHeap.lstHeap(HeapID), 1, TabStops()
'''         frmHeap.Show 1
'''         frmHeap.lstHeap(HeapID).Visible = False
'''         success = True
      End Select

HeapExit:
Exit Sub
                  
BinarySearchHeap:
'This has no use outside this procedure, so done as a Gosub instead of a separate Function
'Takes key$ and .Listcount
'If found, returns .ListIndex = set appropriately
'otherwise returns .ListIndex = -1 and InsertPtr = value required as param to .Additem

   frmHeap.lstHeap(HeapID).ListIndex = -1                '14Sep98 CKJ Binary search
   top = frmHeap.lstHeap(HeapID).ListCount               '0 or 1 to n
   bot = 1
   sch = 1
   lenkey = Len(key$)
   Do While top >= bot                                   '  -- Binary Search --
      sch = (top + bot) \ 2
      Select Case Left$(frmHeap.lstHeap(HeapID).List(sch - 1), lenkey)
         Case Is < key$                                  'less than required item
            bot = sch + 1                                'set bottom above this line
            sch = sch + 1                                'insert would be above this line
         Case Is > key$                                  'greater than required item
            top = sch - 1                                'set top below this line
         Case Else                                       'equal to item
            frmHeap.lstHeap(HeapID).ListIndex = sch - 1  '-1 or 0 to n-1
            Exit Do                                      'force loop exit
         End Select
   Loop
   InsertPtr = sch - 1                                   'list is zero indexed
                                                                        
Return

HeapErr:
   'Error Err     'NB enable this line for testing ONLY
Resume HeapExit

End Sub
Sub PutRecordFailure(ErrNumber&, ErrDescription$)
'stubbage
End Sub
Sub popmessagecr(strCaption As String, strMsg As String)
'stubbish
MsgBox strMsg
End Sub
Function TrueFalse(Item$) As Boolean
'31Aug96 CKJ Written
'            Takes a string & returns 0 or -1
'            Y, T, -1     -> -1
'            all else     -> 0
'16Oct96 CKJ Added GetYN$(1)
' 8Jul97 CKJ Added '1' to list of True items
   
   Select Case Trim$(UCase$(Item$))
      Case "Y", "T", "1", "-1": TrueFalse = -1
      Case Else:                           TrueFalse = 0
      End Select

End Function
Function Iff(expr As Variant, IfTrue As Variant, IfFalse As Variant) As Variant
'14Apr97 CKJ Small but useful procedure, which emulates IIF(Expr, "Res1", "Res2")
'            but without the fatal flaw when immediate strings are used (as above)
'            DO NOT use IIF as memory corruption can occur.
   
   If expr Then
         Iff = IfTrue
      Else
         Iff = IfFalse
      End If

End Function
Function TxtDPatmed(default As String, entry As String, found As Integer) As String
'20Jul98 EAC make language aware
'09May05 Was Txtd2$()

   TxtDPatmed = TxtD(dispdata$ & "\patmed.ini", "", default, entry, found)

End Function
Sub waitforticks(i As Integer)
'stub
End Sub
Sub getdrug(d As DrugParameters, ByVal productstockID As Long, foundPtr As Long, ByVal lockdrug As Boolean)
'-----------------------------------------------------------------------------
' if finddnum >0 then assumes you want drug in position found else the format
' has been tested and a drug with the field already filled will be returned
' with 'd' filled completely
' NB: foundptr is not boolean- it contains the PK of the found drug.
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting. Note that locking the
'            drug is illegal and is refused, and that Putdrug is disabled. GetNOD is also modified.
'09May05 CKJ Removed FormularyExt as prescribing would be done in Web
'            Locking not yet implemented in SQL
'            Note that D is blanked if drug not found
'            Site to be handled in SQL via sessionID
'-----------------------------------------------------------------------------
''Static nod&, lastdispdata$

''Dim AltDispdata As String

''   If siteinfo$("FormularyEXT", "") = "" Then                                '09Apr01 CKJ Formulary site not defined
''         AltDispdata$ = dispdata$                                            '            use standard one
''      Else                                                                   '            Formulary site is defined
''         If lockdrug Then                                                    '            Locking drugs is not permitted
''               popmessagecr ".", "Prescribing account cannot lock the Product File, request ignored"
''               lockdrug = False
''            End If
''         AltDispdata$ = siteinfo$("FormularyDRV", "") & "\dispdata." & siteinfo$("FormularyEXT", Right$(dispdata$, 3))
''      End If

''   If lastdispdata$ <> AltDispdata$ Or getdchan = 0 Then                     '09Apr01 CKJ use Formulary files
''         If getdchan Then Close #getdchan
''         openrandomfile AltDispdata$ & "\prodinfo.v8", Len(d), getdchan      '09Apr01 CKJ use Formulary files
''         lastdispdata$ = AltDispdata$
''         getnod nod& 'ASC 31Mar93
''      End If
Dim blnOK As Boolean
Dim intCount As Integer
Dim rsLock As ADODB.Recordset
Dim strMsg As String
Dim strAns As String
Dim intloop As Integer
Dim blnOCX As Boolean   '31Jul06 TH Added to identify if we are from OCX. If so then we dont give the user any option
                        '           but to wait if the record is locked
                        
                        

   
   foundPtr& = 0                    'NB: *NOT* Boolean!
   d.ProductID = 0                  '09May05 added
   
   If productstockID > 0 Then
      GetProductNL productstockID, d
   ElseIf RTrim$(d.SisCode) <> "" Then
      GetProductNLbyNSV UCase$(RTrim$(d.SisCode)), d
   ElseIf RTrim$(d.barcode) <> "" Then
      GetProductNLbyBarcode RTrim$(d.barcode), d
   Else
      '!!** cancel locking hint?
      Exit Sub              'no barcode or siscode specified   <== WAY OUT
   End If
   
   foundPtr = d.productstockID
   If foundPtr = 0 Then
         'd.Description = "*** Product code " & d.SisCode & " not found ***"
		d.LabelDescription = "*** Product code " & d.SisCode & " not found ***"	
		d.DrugDescription = "*** Product code " & d.SisCode & " not found ***"	
   Else
      If lockdrug Then 'Stop            '!!** Need locking hint here
      'OPEN TRANSACTION
      
      blnOK = False
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
         'gTransport.Connection.Execute "Begin Transaction"
         If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then
            gTransport.Connection.Execute "Begin Transaction"
         End If
         If Trim$(UCase(App.FileDescription)) = "DISPENSING COMPONENT" Then
            blnOCX = True
         Else
            blnOCX = False
         End If
         Do While Not blnOK
            intCount = 0
            Set rsLock = TableRowLock("ProductStock", d.productstockID, g_SessionID)
            If rsLock.EOF Or rsLock.RecordCount > 1 Then
               Do While gTransport.IsInTransaction(g_SessionID)
                  'Here are going to rollback ay outstanding transactions prior to msg display
                  'We keep a count so we can reinstitute them
                  If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
                  intCount = intCount + 1
               Loop
               If blnOCX Then
                  strAns = "Y"
                  strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & "Reason Unknown"
                  popmessagecr "EMIS Health", strMsg
               Else
                  strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & "Reason Unknown" & _
                           crlf & crlf & "OK to Retry ? (No Will exit Application)"
                  strAns = "Y"
                  ''popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
               End If
               If strAns = "N" Then
                  'Exit App
                  BlankWProduct d
                  foundPtr = 0
                  productstockID = 0
                  GoTo CloseApplication
               Else
                  blnOK = False
               End If
            Else
               If GetField(rsLock!sessionID) = g_SessionID Then
                  blnOK = True 'There is a lock - it is ours !
               Else
               'Geuine lock from another identifiable source
                  Do While gTransport.IsInTransaction(g_SessionID)
                     'Here are going to rollback ay outstanding transactions prior to msg display
                     'We keep a count so we can reinstitute them
                     If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
                     intCount = intCount + 1
                  Loop
                  If blnOCX Then
                     strAns = "Y"
                     strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & _
                              "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal)
                     popmessagecr "EMIS Health", strMsg
                  Else
                     strMsg = "Could not lock ProductStock Record Number " & CStr(d.productstockID) & crlf & _
                              "Record is currently locked by User " & RtrimGetField(rsLock!User) & " on Terminal " & RtrimGetField(rsLock!terminal) & _
                              crlf & crlf & "OK to Retry ? (No will exit " & App.EXEName & ")"
                     strAns = "Y"
                     ''popmsg "ASCribe", strMsg, MB_YESNO + MB_DEFBUTTON1 + MB_ICONQUESTION, strAns, k.escd
                  End If
                  If strAns = "N" Then
                     'Exit App
                     BlankWProduct d
                     foundPtr = 0
                     productstockID = 0
                     GoTo CloseApplication
                  Else
                     blnOK = False
                  End If
               
               End If
            
            End If
            
            If Not blnOK Then
               'Restore any Transactions from before rollbacks for any modal display
               For intloop = 1 To intCount
                  gTransport.Connection.Execute "Begin Transaction"
               Next
               
            End If
         Loop
      
      Else
         Do While Not blnOK
            gTransport.Connection.Execute "Begin Transaction"
            blnOK = gTransport.GetRowLock(g_SessionID, "ProductStock", d.productstockID) '21Oct04 TH Testage
            If Not blnOK Then
               gTransport.Connection.Execute "RollBack Transaction"                 '06Jan06 TH Moved from below msgbox call
               popmessagecr "", "Waiting to lock product record. Press OK to retry" '           Converted from msgbox
            End If
         Loop
      End If
      GetProductNL d.productstockID, d '09Nov05 TH get the definitive read here as it will be now safely behind
                                       '           the lock. Extra read, but as the original read may be without
                                       '           the key this seems for now the best way. Open for review
      End If
      '----------------
   End If
Exit Sub

CloseApplication:
On Error Resume Next                  'SQL If there has been an error then we should try and roll back to unlock any record.
   Do While gTransport.IsInTransaction(g_SessionID)
      'Here are going to rollback any outstanding transactions prior to unloading completely
      If gTransport.IsInTransaction(g_SessionID) Then gTransport.Connection.Execute "Rollback Transaction"
   Loop
   If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
      UnlockDatabase g_SessionID
   End If
   'Now we have cleaned up the database we are ready to clean up and close
   'We will call a closedown routine that can be different for each app type using this library
   PutRecordFailure "-1", "Failed to Lock ProductStock Record"
   On Error GoTo 0

End Sub
Sub putdrug(d As DrugParameters)
'------------Puts a drug record on disc and unlocks it------------------------
'18Aug93 CKJ We need to be able to unlock a drug without writing back to it.
'            However since space is crucial in some progs, this approach has
'            been used even though it does not conform to company style.
'            To unlock without writing call    PutDrug d,-F
'15Mar01 TH  Added extra check to ensure profile is put back to correct drug
'09Apr01 CKJ Prescribing Ward modification. If siteinfo.ini FormularyEXT <>"" then use this dispdata for
'            every drug request, instead of the default dispdata. In effect this ensures that the ward
'            always sees the dispensary drug file, regardless of any other setting.
'            Putdrug is disabled so that no updates can occur in the dispensary caused by ward prescribing
'01Jun02 ALL/ATW 'f' parameter renamed to 'i_lngPointer'
'09May05 CKJ Calls PutProductNL to do the writing. i_lngPointer As Long removed as the keys are part of drugparameters
'            No locking is now done here, as this is handled outside.

'Dim SupProfile As TSupProfile
Dim success%
Dim blnNotintransaction As Boolean
   
''   If siteinfo$("FormularyEXT", "") <> "" Then                               '09Apr01 CKJ Formulary site is defined
''         popmessagecr ".", "Prescribing account cannot update the Product File, request ignored"
''         Exit Sub                                                            '   "        <===== WAY OUT
''      End If

   'If we are not using the primary suppplier then write the profile fields to the SupProfile record,
   'load the primary supplier profile and populate the d structure before the save.
'SQL Now this should all be handled in PutProductNL !!!!!!!!
'''   If Not d.PrimarySup Then                        'SQL Replaced
'''   'If Trim$(AlternativeSupplier$) <> "" Then      '  "
'''         DrugToSupProfile d, SupProfile
'''         SupProfile.supcode = AlternativeSupplier$
'''         PutSupProfile SupProfile, success%
'''         'If Trim$(PrimarySupProfile.supcode) <> Trim$(AlternativeSupplier$) Then           '14Sep99 CFY Added
'''         If Trim$(UCase$(PrimarySupProfile.SisCode)) = Trim$(UCase$(d.SisCode)) And Trim$(PrimarySupProfile.supcode) <> Trim$(AlternativeSupplier$) Then  '15Mar01 TH Added extra check to ensure profile is put back to correct drug
'''              SupProfileToDrug d, PrimarySupProfile
'''            End If
'''      End If
   
''   Select Case i_lngPointer
''      Case Is > 0
''         LSet r = d
''         PutRecordL r, i_lngPointer, getdchan, Len(d)            ' 01Jun02 ALL/ATW Parentheses removed
''      Case Is < 0
''         '08Feb96 EAC Use new (un)lockrecord
''         UnlockRecord getdchan, -i_lngPointer, Len(d)
''      End Select
   
   If d.productstockID = 0 Then
      blnNotintransaction = True 'There should be no 'lock' on a new product
      
   Else
      blnNotintransaction = False
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then
         If Not TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLockingStandard", 0)) Then gTransport.Connection.Execute "begin Transaction"
      End If
   End If
   
   
   success = PutProductNL(d)
   'commit or rollback on the basis of success
   
      
   If Not blnNotintransaction Then   'New product - we dont have any transactions open here (hopefully)
      If success Then
         ''gTransport.Connection.CommitTrans
         gTransport.Connection.Execute "Commit Transaction"
      Else
      '???/what do we do here ? Hmmm
         MsgBox "Could not save changes to product " & d.SisCode
         '''WriteLog dispdata$ & "\locking.txt", SiteNumber, UserID$, "Could not save changes to product " & d.SisCode
         gTransport.Connection.Execute "RollBack Transaction"
      End If
      If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "Y", "SessionLocking", 0)) Then TableRowUnLock "ProductStock", d.productstockID, g_SessionID

   End If
   
   'If TrueFalse(TxtD(dispdata$ & "\ascribe.ini", "", "N", "SessionLocking", 0)) Then TableRowUnLock "ProductStock", d.ProductStockID, g_SessionID
   
   'Set the drug structure to the state it was when passed into this procedure
   'SQL Frankly my Dear we no longer give a damn !!!
'''   If Trim$(AlternativeSupplier$) <> "" Then
'''         SupProfileToDrug d, SupProfile
'''         d.supcode = PrimarySupProfile.supcode
'''      End If
         
End Sub

Public Sub dummyEAN(ip As String, op As String)
'Create pseudo EAN code from NSVcode
'ABC123D' becomes '65 66 67 123 68 0 x' where x is the calculated check digit
' 8Mar97 CKJ Modified to accept any combination of alphanumerics, with the
'            proviso that the total number of digits needed is 12 or less

Dim tmp As Integer
Dim inst As String
Dim count As Integer

   op = ""
   If Len(ip) = 7 Then
         inst = UCase$(ip)
         For count = 1 To 7
            tmp = Asc(Mid$(inst, count, 1))           'ASCII value of character
            Select Case tmp
               Case 48 To 57: op = op & Chr$(tmp)    '0 to 9      0-9 unchanged
               Case Else:     op = op & Format$(tmp) 'A to Z etc  A -> 65
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

'------------------------------- Transport Layer Calls --------------------------------
Sub gTransportConnectionExecute(ByVal Parameters As String)
'08Aug12 CKJ Wrapper written
'            CAUTION: New transport layer does not support transactions initiated from the client
'            as there is no 'connection' object as such. Each call has to be completed in one go.
'            This wrapper is therefore not a substitute for refactoring transaction handling.
'            As a double check, no other commands can be executed & any attempt raises an error.
'18Sep12 TH Removed ref to web data layer

   Select Case LCase(Parameters)
      Case "begin transaction", "commit transaction", "rollback transaction"
         If Not gTransport Is Nothing Then
            'If TypeOf gTransport Is PharmacyWebData.Transport Then
               'no action
            'Else
               If Not gTransport.Connection Is Nothing Then
                  gTransport.Connection.Execute Parameters
               End If
            'End If
         End If
      Case Else
         Err.Raise 32767, OBJNAME & "gTransportConnectionExecute", "Cannot execute '" & Parameters & "'"
      End Select
   
End Sub

Function gTransportIsInTransaction(ByVal sessionID As Long) As Boolean
'08Aug12 CKJ Wrapper written
'18Sep12 TH Removed ref to web data layer

Dim result As Boolean
   
   result = False
   
   If Not gTransport Is Nothing Then
      'If TypeOf gTransport Is PharmacyWebData.Transport Then
         'no action; return False
      'Else
         If Not gTransport.Connection Is Nothing Then
            result = gTransport.IsInTransaction(g_SessionID)
         End If
      'End If
   End If

   gTransportIsInTransaction = result
   
End Function
 

