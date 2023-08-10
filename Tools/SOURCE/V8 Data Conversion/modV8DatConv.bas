Attribute VB_Name = "modV8DatConv"
'----------------------------------------------------------------------------------
'
' Purpose:
'
'
' Modification History:
'  11Feb05 EAC  Written
'  13Jul10 EAC  F0090667: ConvertFormulaTable - Correct conversion of the quantity fields.
'  04Nov11 CKJ  PN defaults, products & rules added
'  07Nov11 CJK  PN Version table conversion added
'  08Nov11 CKJ  Added Rule Exclusion List from DSS
'  09Nov11 CKJ  Added LinkCodes to PNCodes, * to % replacement on RuleSQL
'  10Nov11 CKJ  Added single quotes round True and False on RuleSQL
'               ASCreplace: Corrected handling of case insensitive replace
'  11Nov11 CKJ  Built as 1.6.1 for internal test only, version raised to 1.6.2
'               Removed PN Patient data option
'  18Jan12 CKJ  Convert PN StdReg table
'  23Jan12 CKJ  Added PN Prescription Pro-formas
'  27Jan12 CKJ  Added StockLookup to PNProduct
'               Raised version to 1.6.3 built for internal test
'  23Aug12 TH   Revamp to supplier conversion and app in general
'  15Jul13 XN   35617 added gDSS and gOnlyOnePNRow Added handling of single PN product, or rule
'                     ConvertTPNproductDBs:  Added handling of single PN product
'                     ConvertTPNproductDB:
'                     ConvertPNproductTable
'                     ConvertTPNruleDBs:     Added handling of single PN rule
'                     ConvertTPNruleDB:
'                     ConvertPNruleTable
'  4Aug13  XN   71349 Skip updating WDirtection, WConfiguration, WLookup if eixsting row's DSS flag is set
'  3Sep13  XN   72436 failed converting PN Log data as missing RequestID_Regimen parameter
'  22May14 XN   Split BatchStockLevel conversion from WFormulary covertion  81731
'  11Nov14 XN   53175 ConvertExtraSupplierData: Better error if notes length is too long
'  12Nov14 XN   The supplier is now converted into WSupplier_Old table and is then
'               converted into WSupplier2, WCustomer, and WWardProductList tables
'               Ward stock data is converted to WWardStockList_Old and converted into WWardProductListLine 103883
'  24Feb15 XN   95647 ConvertPNproductTable Prevent protien falling through to Case Else
'  07Apr16 XN   123082: PharmacyLog added Negative and GainLoss log
'  11Nov16 TH   BuildPharmacyCrystalReportAdoCmdObject: Written Based on rtf Conversion routines TFS 157972
'  15Nov16 TH   ConvertCrystalReports: ConvertCrystalReport: Written Based on rtf import TFS 157972
'  05Dec16 TH   ConvertPharmacyRTFReports: Written Based loosely on rtf import TFS 157969
'  08Jan17 TH   ConvertPharmacyPILs: Written Based on ConvertPharmacyRTFReports TFS 157969
'  12Jan17 TH   ConvertLicenseFile: Written (TFS 156988)
'  13Jan17 TH   fLX: Ported and tinkered with to allow the license file conversion (TFS 156988)
'  13Jan17 TH   GetTextFile: Ported and tinkered with to allow the license file conversion (TFS 156988)
'  13Jan17 TH   decodehex: Ported  to allow the license file conversion (TFS 156988)
'  10Feb17 TH   ConvertPharmacyRTFReport: Use old Load routine in order to preserve file as per standard system (TFS 176550)
'  09Mar17 TH   ConvertCrystalReport: Added crystal report file check (TFS 178772)
'  09Mar17 TH   Fileexists: Ported purely for crystal report file check (TFS 178772)
'  27Mar17 TH   ConvertPharmacyPILs: Added check on PIL directory (TFS 178772)
'  27Mar17 TH   ConvertPharmacyRTFReport: Fix to ensure filename isnt interpreted in path (TFS 180785)

'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const CLASS_NAME = "modV8DatConv"

Public gDebug        As Boolean
Public gDSS          As Boolean  ' If user is DSS (set by command line setting /DSS) 15Jul13 XN 35617
Public gOnlyOnePNRow As Boolean  ' Only for DSS user forces convertion of only 1 PN Product, or PN Rule (so can't send everything across) set by command line setting /) 15Jul13 XN 35617

Private Type pointertype
   ptr As Long
End Type  ' len=4

Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Private mintFileHandle As Integer


   
Public Function AddSiteNumbers(ByVal lngSessionID As Long, _
                               ByVal strDbConn As String, _
                               ByRef astrDispdataNos() As String, _
                               ByRef astrPatdataNos() As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  08Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "AddSiteNumbers"

Dim adoSiteCmd As ADODB.Command

Dim udtError As udtErrorState
                                                        
Dim lngCount As Long


   On Error GoTo ErrorHandler


   BuildV8SiteAdoCmdObject strDbConn, _
                           lngSessionID, _
                           adoSiteCmd


   For lngCount = LBound(astrDispdataNos) To UBound(astrDispdataNos)
      adoSiteCmd.Parameters("sitenumber").value = Val(astrDispdataNos(lngCount))
      adoSiteCmd.Execute , , adExecuteNoRecords
      DoEvents
   Next
   
   
   For lngCount = LBound(astrPatdataNos) To UBound(astrPatdataNos)
      adoSiteCmd.Parameters("sitenumber").value = Val(astrPatdataNos(lngCount))
      adoSiteCmd.Execute , , adExecuteNoRecords
      DoEvents
   Next

Cleanup:

   On Error Resume Next
   adoSiteCmd.ActiveConnection.Close
   Set adoSiteCmd.ActiveConnection = Nothing
   Set adoSiteCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function BuildV8FilePath(ByVal strDataDrive As String, _
                                ByVal enumFileLocation As enumV8FileLocation, _
                                ByVal strSiteNumber As String, _
                                ByVal strFileName As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8FilePath"

Dim udtError As udtErrorState
                                                                  
Dim strReturn As String


   On Error GoTo ErrorHandler

   strReturn = strDataDrive
   If enumFileLocation = enumV8FileLocation.eDispdata Then strReturn = strReturn & "\dispdata."
   If enumFileLocation = enumV8FileLocation.ePatdata Then strReturn = strReturn & "\patdata."
   If enumFileLocation = enumV8FileLocation.eAscroot Then strReturn = strReturn & "\ascroot"
   If enumFileLocation <> enumV8FileLocation.eAscroot Then strReturn = strReturn & Right$("000" & strSiteNumber, 3)
   If Len(strFileName) > 0 Then strReturn = strReturn & "\" & strFileName

   BuildV8FilePath = strReturn
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                                 
End Function
Private Sub BuildV8GpAdoCmdObject(ByVal strDbConn As String, _
                                  ByVal lngSessionID As Long, _
                                  ByVal lngLocationID_Site As Long, _
                                  ByRef adoGpCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8GpAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoGpCmd = New ADODB.Command
   
   With adoGpCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8GpInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("description", adVarChar, adParamInput, 30, "")
      .Parameters.Append .CreateParameter("inuse", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("entityid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8ReadptrAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoReadptrCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Nov05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8ReadptrAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoReadptrCmd = New ADODB.Command
   
   With adoReadptrCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ReadptrInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("category", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("value", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("wfilepointerid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub BuildV8ConsSpecAdoCmdObject(ByVal strDbConn As String, _
                                        ByVal lngSessionID As Long, _
                                        ByVal lngLocationID_Site As Long, _
                                        ByRef adoSupCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Dec05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8ConsSpecAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoSupCmd = New ADODB.Command
   
   With adoSupCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ConsultantSpecialtyInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("conscode", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("specialty", adVarChar, adParamInput, 5, "")
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8WardSpecAdoCmdObject(ByVal strDbConn As String, _
                                        ByVal lngSessionID As Long, _
                                        ByVal lngLocationID_Site As Long, _
                                        ByRef adoSupCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8WardSpecAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoSupCmd = New ADODB.Command
   
   With adoSupCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WardSpecialtyInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("ward", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("specialty", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("wwardlinkspecialtyid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8ExtraSupplierDataAdoCmdObject(ByVal strDbConn As String, _
                                                 ByVal lngSessionID As Long, _
                                                 ByVal lngLocationID_Site As Long, _
                                                 ByRef adoSupCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8ExtraSupplierDataAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoSupCmd = New ADODB.Command
   
   With adoSupCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WExtraSupplierDataInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("supcode", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("currentcontractdata", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("newcontractdata", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("dateofchange", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("contactname1", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("contactname2", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("notes", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("wextrasupplierdataid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8WSLayoutAdoCmdObject(ByVal strDbConn As String, _
                                        ByVal lngSessionID As Long, _
                                        ByVal lngLocationID_Site As Long, _
                                        ByRef adoSupCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8WSLayoutAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoSupCmd = New ADODB.Command
   
   With adoSupCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WWardStocklistInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("barcode", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("dailyissue", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("screenposn", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("nsvcode", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("titletext", adVarChar, adParamInput, 56, "")
      .Parameters.Append .CreateParameter("printlabel", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("sitename", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("topuplvl", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("lastissue", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("packsize", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("lastissuedate", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("localcode", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("wwardstocklistid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8DirectionAdoCmdObject(ByVal strDbConn As String, _
                                         ByVal lngSessionID As Long, _
                                         ByVal lngLocationID_Site As Long, _
                                         ByRef adoDirCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8DirectionAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoDirCmd = New ADODB.Command
   
   With adoDirCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8DirectionInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, , lngLocationID_Site)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 12, "")
      .Parameters.Append .CreateParameter("route", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("equaldose", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("equalinterval", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("timeunits", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("repeatinterval", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("repeatunits", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("courselength", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("courseunits", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("abstime", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("days", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("dose1", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose2", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose3", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose4", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose5", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose6", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose7", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose8", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose9", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose10", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose11", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dose12", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("time1", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time2", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time3", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time4", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time5", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time6", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time7", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time8", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time9", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time10", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time11", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time12", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("deletedby", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("approvedby", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("revisionno", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("deleted", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("location", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("directs", adVarChar, adParamInput, 140, "")
      .Parameters.Append .CreateParameter("prn", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("sortcode", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("dss", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("hideprescriber", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("manualqtyentry", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("statdoseflag", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("wdirectionsid", adInteger, adParamOutput)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8RxIdxAdoCmdObject(ByVal strDbConn As String, _
                                     ByVal lngSessionID As Long, _
                                     ByVal lngLocationID_Site As Long, _
                                     ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8RxIdxAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8RxIdxInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("SiteID", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("V8PatientId", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("RxFileName", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("RxPosition", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("V8RxIdxID", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
'Private Sub BuildV8RxLogAdoCmdObject(ByVal strDbConn As String, _
'                                     ByVal lngSessionID As Long, _
'                                     ByVal lngLocationID_Site As Long, _
'                                     ByRef adoCmd As ADODB.Command)
''----------------------------------------------------------------------------------
''
'' Purpose:
''
'' Inputs:
''     lngSessionID        :  Standard sessionid
''
'' Outputs:
''
''     returns an errors as <BrokenRules/> XML string
''
'' Modification History:
''  09Jan06 EAC  Written
''
''----------------------------------------------------------------------------------
'
'Const SUB_NAME = "BuildV8RxLogAdoCmdObject"
'
'Dim udtError As udtErrorState
'
'Dim adoConn As ADODB.Connection
'
'   On Error GoTo ErrorHandler
'
'   Set adoConn = New ADODB.Connection
'   adoConn.ConnectionString = strDbConn
'   adoConn.open
'
'   Set adoCmd = New ADODB.Command
'
'   With adoCmd
'      Set .ActiveConnection = adoConn
'      .CommandType = adCmdStoredProc
'      .CommandText = "pV8RxLogInsert"
'      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
'      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
'      .Parameters.Append .CreateParameter("dircode", adVarchar, adParamInput, 12, "")
'      .Parameters.Append .CreateParameter("route", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("equalinterval", adDouble, adParamInput, 1, 0)
'      .Parameters.Append .CreateParameter("timeunits", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("repeatinterval", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("repeatunits", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("abstime", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("days", adVarchar, adParamInput, 1, Chr$(0))
'      .Parameters.Append .CreateParameter("baseprescriptionid", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose1", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose2", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose3", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose4", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose5", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("dose6", adDouble, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("time1", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("time2", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("time3", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("time4", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("time5", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("time6", adVarchar, adParamInput, 4, "")
'      .Parameters.Append .CreateParameter("flags", adVarchar, adParamInput, 1, Chr$(0))
'      .Parameters.Append .CreateParameter("prescriptionid", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("reconvol", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("container", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("reconabbr", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("diluentabbr", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("finalvolume", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("drdirection", adVarChar, adParamInput, 105, "")
'      .Parameters.Append .CreateParameter("containersize", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("infusiontime", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("prn", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("patid", adVarchar, adParamInput, 10, "")
'      .Parameters.Append .CreateParameter("siscode", adVarchar, adParamInput, 7, "")
'      .Parameters.Append .CreateParameter("text", adVarChar, adParamInput, 180, "")
'      .Parameters.Append .CreateParameter("startdate", adDate, adParamInput, 8, Null)
'      .Parameters.Append .CreateParameter("stopdate", adDate, adParamInput, 8, Null)
'      .Parameters.Append .CreateParameter("isstype", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("lastqty", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("lastdate", adVarchar, adParamInput, 6, "")
'      .Parameters.Append .CreateParameter("topupqty", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("dispid", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("prescriberid", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("pharmacistid", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("stoppedby", adVarchar, adParamInput, 3, "")
'      .Parameters.Append .CreateParameter("rxstatus", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("needednexttime", adVarchar, adParamInput, 1, "")
'      .Parameters.Append .CreateParameter("rxstartdate", adDate, adParamInput, 8, Null)
'      .Parameters.Append .CreateParameter("nodissued", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("batchnumber", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("extraflags", adVarchar, adParamInput, 1, Chr$(0))
'      .Parameters.Append .CreateParameter("deletedate", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("rxnodissued", adDouble, adParamInput, 8, 0)
'      .Parameters.Append .CreateParameter("rxfilename", adVarChar, adParamInput, 6, vbNullString)
'      .Parameters.Append .CreateParameter("rxposition", adInteger, adParamInput, 4, 0)
'      .Parameters.Append .CreateParameter("wlabelhistoryid", adInteger, adParamOutput, 4)
'   End With
'
'
'Cleanup:
'
'   On Error Resume Next
'   Set adoConn = Nothing
'
'   On Error GoTo 0
'   BubbleOnError udtError
'
'Exit Sub
'
'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
'
'End Sub

Private Sub BuildV8LabelAdoCmdObject(ByVal strDbConn As String, _
                                     ByVal lngSessionID As Long, _
                                     ByVal lngLocationID_Site As Long, _
                                     ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8LabelAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WLabelInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("dircode", adVarChar, adParamInput, 12, "")
      .Parameters.Append .CreateParameter("route", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("equalinterval", adDouble, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("timeunits", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("repeatinterval", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("repeatunits", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("abstime", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("days", adVarChar, adParamInput, 1, Chr$(0))
      .Parameters.Append .CreateParameter("baseprescriptionid", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose1", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose2", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose3", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose4", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose5", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("dose6", adDouble, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("time1", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time2", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time3", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time4", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time5", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("time6", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("flags", adVarChar, adParamInput, 1, Chr$(0))
      .Parameters.Append .CreateParameter("prescriptionid", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("reconvol", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("container", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("reconabbr", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("diluentabbr", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("finalvolume", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("drdirection", adVarChar, adParamInput, 105, "")
      .Parameters.Append .CreateParameter("containersize", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("infusiontime", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("prn", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("patid", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("siscode", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("text", adVarChar, adParamInput, 180, "")
      .Parameters.Append .CreateParameter("startdate", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("stopdate", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("isstype", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("lastqty", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("lastdate", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("topupqty", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("dispid", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("prescriberid", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("pharmacistid", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("stoppedby", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("rxstatus", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("needednexttime", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("rxstartdate", adDate, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("nodissued", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("batchnumber", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("extraflags", adVarChar, adParamInput, 1, Chr$(0))
      .Parameters.Append .CreateParameter("deletedate", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("rxnodissued", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("filename", adVarChar, adParamInput, 12, vbNullString)
      .Parameters.Append .CreateParameter("fileposition", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("wlabelhistoryid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8SpecialtyAdoCmdObject(ByVal strDbConn As String, _
                                          ByVal lngSessionID As Long, _
                                          ByVal lngLocationID_Site As Long, _
                                          ByRef adoConsCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  28Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8SpecialtyAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoConsCmd = New ADODB.Command
   
   With adoConsCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8SpecialtyInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("description", adVarChar, adParamInput, 30, "")
      .Parameters.Append .CreateParameter("specialtyid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8ConsultantAdoCmdObject(ByVal strDbConn As String, _
                                          ByVal lngSessionID As Long, _
                                          ByVal lngLocationID_Site As Long, _
                                          ByRef adoConsCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'  20Oct09 EAC  Increased description length to 128 characters.
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8ConsultantAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoConsCmd = New ADODB.Command
   
   With adoConsCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ConsultantInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("description", adVarChar, adParamInput, 128, "")
      .Parameters.Append .CreateParameter("inuse", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("entityid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildMetadataAdoCmdObject(ByVal strDbConn As String, _
                                      ByVal lngSessionID As Long, _
                                      ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildMetadataAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ConversionMetadataSetup"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8ConfigAdoCmdObject(ByVal strDbConn As String, _
                                      ByVal lngSessionID As Long, _
                                      ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'  08Feb10 EAC  F0075670 - Changed the stored procedure call to pV8ConfigurationInsert to prevent errors
'                          when processing settings that have already been converted.
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8ConfigAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ConfigurationInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("category", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("section", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("key", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("value", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("wconfigurationid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub BuildV8LookupAdoCmdObject(ByVal strDbConn As String, _
                                      ByVal lngSessionID As Long, _
                                      ByVal lngLocationID_Site As Long, _
                                      ByRef adoContextCmd As ADODB.Command, _
                                      ByRef adoLookupCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'  04Aug13 XN   71349 Skip updating WDirtection, WConfiguration, WLookup if
'               eixsting row's DSS flag is set
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8LookupAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoLookupCmd = New ADODB.Command
   
   With adoLookupCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      ' .CommandText = "pWLookupInsert"  4Aug13 XN 71349 Skip updating WDirtection, WConfiguration, WLookup if eixsting row's DSS flag is set
      .CommandText = "pV8WLookupInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("wlookupcontextid", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("expansion", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("inuse", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("wlookupid", adInteger, adParamOutput, 4)
   End With
   
   Set adoContextCmd = New ADODB.Command
   
   With adoContextCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8LookupContextInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("context", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("wlookupcontextid", adInteger, adParamOutput, 4, 0)
   End With
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8SupProfAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8SupProfAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8SupplierProfileInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("nsvcode", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("supcode", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("primarysupplier", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("cost", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("contno", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("reorderpcksize", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("reorderlvl", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("reorderqty", adVarChar, adParamInput, 6, "")
      .Parameters.Append .CreateParameter("sislistprice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("contprice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("leadtime", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("lastreconcileprice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("tradename", adVarChar, adParamInput, 30, "")
      .Parameters.Append .CreateParameter("supprefno", adVarChar, adParamInput, 20, "")
      .Parameters.Append .CreateParameter("altbarcode", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("varrate", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("wsupplierprofileid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8StockLabelAdoCmdObject(ByVal strDbConn As String, _
                                          ByVal lngSessionID As Long, _
                                          ByVal lngLocationID_Site As Long, _
                                          ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8StockLabelAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8StockLabelInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("id", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("drugcode", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("wardcode", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("rtffilename", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("wstocklabelid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8MediateAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8MediateAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8MediateInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("OrderNo", adVarChar, adParamInput, 16, "")
      .Parameters.Append .CreateParameter("OPCode", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("LinkCode", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("LocalCode", adVarChar, adParamInput, 22, "")
      .Parameters.Append .CreateParameter("Paydate", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("InvoiceNo", adVarChar, adParamInput, 20, "")
      .Parameters.Append .CreateParameter("PWOQty", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOContractNo", adVarChar, adParamInput, 16, "")
      .Parameters.Append .CreateParameter("PWOQtyRateApplies", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("PWOLineExVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOVatCode", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("PWOVatAmount", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOLineIncVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVQty", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVContractNo", adVarChar, adParamInput, 35, "")
      .Parameters.Append .CreateParameter("INVLineTotal", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVVatAmount", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVLineExVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVVatCode", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("ASCIssuePrice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCPriceLastPaid", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCContractPrice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCPriceLastReconciled", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCContractNumber", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("ErrorCode", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("StatusFlag", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("DateLastModified", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("wmediateid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8FormulaAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8FormulaAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8FormulaInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("id", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("authorised2", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("layout2", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("nsvcode", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("code1", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code2", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code3", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code4", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code5", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code6", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code7", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code8", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code9", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code10", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code11", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code12", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code13", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code14", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("code15", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("qty1", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty2", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty3", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty4", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty5", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty6", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty7", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty8", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty9", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty10", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty11", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty12", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty13", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty14", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("qty15", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("type1", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type2", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type3", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type4", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type5", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type6", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type7", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type8", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type9", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type10", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type11", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type12", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type13", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type14", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("type15", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("method", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("totalqty", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("numoflabels", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("label", adVarChar, adParamInput, 5000, "")
      .Parameters.Append .CreateParameter("extralabels", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("dosingunits", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("d1", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d2", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d3", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d4", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d5", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d6", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d7", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d8", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d9", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d10", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d11", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d12", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d13", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d14", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("d15", adVarChar, adParamInput, 60, "")
      .Parameters.Append .CreateParameter("authorised", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("authorised_date", adDate, adParamInput, , Null)
      .Parameters.Append .CreateParameter("layout", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("wformulaid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8LayoutAdoCmdObject(ByVal strDbConn As String, _
                                      ByVal lngSessionID As Long, _
                                      ByVal lngLocationID_Site As Long, _
                                      ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8LayoutAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8LayoutInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("id", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("patientspersheet", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("layout", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("linetext", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("inglinetext", adVarChar, adParamInput, 1024, "")
      .Parameters.Append .CreateParameter("prescription", adVarChar, adParamInput, 5000, "")
      .Parameters.Append .CreateParameter("name", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("wlayoutid", adInteger, adParamOutput)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub BuildV8MediateArchiveAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8MediateArchiveAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8MediateArchiveInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("OrderNo", adVarChar, adParamInput, 16, "")
      .Parameters.Append .CreateParameter("OPCode", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("LinkCode", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("LocalCode", adVarChar, adParamInput, 22, "")
      .Parameters.Append .CreateParameter("Paydate", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("InvoiceNo", adVarChar, adParamInput, 20, "")
      .Parameters.Append .CreateParameter("PWOQty", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOContractNo", adVarChar, adParamInput, 16, "")
      .Parameters.Append .CreateParameter("PWOQtyRateApplies", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("PWOLineExVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOVatCode", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("PWOVatAmount", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("PWOLineIncVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVQty", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVContractNo", adVarChar, adParamInput, 35, "")
      .Parameters.Append .CreateParameter("INVLineTotal", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVVatAmount", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVLineExVat", adDouble, adParamInput, 0)
      .Parameters.Append .CreateParameter("INVVatCode", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("ASCIssuePrice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCPriceLastPaid", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCContractPrice", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCPriceLastReconciled", adVarChar, adParamInput, 9, "")
      .Parameters.Append .CreateParameter("ASCContractNumber", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("ErrorCode", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("StatusFlag", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("DateLastModified", adVarChar, adParamInput, 10, "")
      .Parameters.Append .CreateParameter("wmediatearchiveid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8BatchStockLevelAdoCmdObject(ByVal strDbConn As String, _
                                               ByVal lngSessionID As Long, _
                                               ByVal lngLocationID_Site As Long, _
                                               ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8BatchStockLevelAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8BatchStockLevelInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("id", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("nsvcode", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("description", adVarChar, adParamInput, 56, "")
      .Parameters.Append .CreateParameter("batchnumber", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("expiry", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("qty", adDouble, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("wbatchstocklevelid", adInteger, adParamOutput, 4)
   End With
   
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8PatientAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoPatCmd As ADODB.Command, _
                                       ByRef adoEpCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8PatientAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoPatCmd = New ADODB.Command
   Set adoEpCmd = New ADODB.Command
   
   With adoPatCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8PatientInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("LocationID_Site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("FilePosn", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("Recno", adVarChar, adParamInput, 10, vbNullString)
      .Parameters.Append .CreateParameter("Caseno", adVarChar, adParamInput, 10, vbNullString)
      .Parameters.Append .CreateParameter("OldCaseno", adVarChar, adParamInput, 10, vbNullString)
      .Parameters.Append .CreateParameter("Surname", adVarChar, adParamInput, 20, vbNullString)
      .Parameters.Append .CreateParameter("Forename", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("DOB", adDate, adParamInput, 8, Null)
      .Parameters.Append .CreateParameter("DOBEstYear", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("DOBEstMonth", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("DOBEstDay", adBoolean, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("Sex", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("Ward", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("Cons", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("Weight", adVarChar, adParamInput, 6, vbNullString)
      .Parameters.Append .CreateParameter("Height", adVarChar, adParamInput, 6, vbNullString)
      .Parameters.Append .CreateParameter("Status", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("Postcode", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("GP", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("HouseNumber", adVarChar, adParamInput, 6, vbNullString)
      .Parameters.Append .CreateParameter("NhNumber", adVarChar, adParamInput, 10, vbNullString)
      .Parameters.Append .CreateParameter("NhNumberValid", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("Title", adVarChar, adParamInput, 5, vbNullString)
      .Parameters.Append .CreateParameter("Address1", adVarChar, adParamInput, 35, vbNullString)
      .Parameters.Append .CreateParameter("Address2", adVarChar, adParamInput, 35, vbNullString)
      .Parameters.Append .CreateParameter("Address3", adVarChar, adParamInput, 35, vbNullString)
      .Parameters.Append .CreateParameter("Address4", adVarChar, adParamInput, 35, vbNullString)
      .Parameters.Append .CreateParameter("EthnicOrigin", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("AliasSurname", adVarChar, adParamInput, 20, vbNullString)
      .Parameters.Append .CreateParameter("AliasForename", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("PPFlag", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("EpisodeNum", adVarChar, adParamInput, 12, vbNullString)
      .Parameters.Append .CreateParameter("Specialty", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("Allergy", adVarChar, adParamInput, 255, vbNullString)
      .Parameters.Append .CreateParameter("Diagnosis", adVarChar, adParamInput, 255, vbNullString)
      .Parameters.Append .CreateParameter("SurfaceArea", adDouble, adParamInput, 8, 0)
      '.Parameters.Append .CreateParameter("Notes", adVarChar, adParamInput, 1024, vbNullString)            '29Nov07 CKJ Changed from varchar 1024 to 8000
      .Parameters.Append .CreateParameter("Notes", adVarChar, adParamInput, 8000, vbNullString)             '   "
      
      .Parameters.Append .CreateParameter("EntityID", adInteger, adParamOutput, 4)
   End With
   
   With adoEpCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8EpisodeInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("idnum", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("entityid", adInteger, adParamInput, 4, -1)
      .Parameters.Append .CreateParameter("patrecno", adVarChar, adParamInput, 10, vbNullString)
      .Parameters.Append .CreateParameter("createddate", adDate, adParamInput, 10, vbNull)
      .Parameters.Append .CreateParameter("createduserid", adVarChar, adParamInput, 3, vbNullString)
      .Parameters.Append .CreateParameter("createdterminal", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("updateddate", adDate, adParamInput, 10, vbNull)
      .Parameters.Append .CreateParameter("updateduserid", adVarChar, adParamInput, 3, vbNullString)
      .Parameters.Append .CreateParameter("updatedterminal", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("class", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("episodenumber", adVarChar, adParamInput, 12, vbNullString)
      .Parameters.Append .CreateParameter("episodeactive", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("facilityid", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("episodeward", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("episoderoom", adVarChar, adParamInput, 12, vbNullString)
      .Parameters.Append .CreateParameter("episodebed", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("attendingdr", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("admitdt", adDate, adParamInput, 10, vbNull)
      .Parameters.Append .CreateParameter("dischargedt", adDate, adParamInput, 10, vbNull)
      .Parameters.Append .CreateParameter("episodecons", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("episodespec", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("episodeweight", adVarChar, adParamInput, 6, vbNullString)
      .Parameters.Append .CreateParameter("episodeheight", adVarChar, adParamInput, 6, vbNullString)
      .Parameters.Append .CreateParameter("episodegp", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("episodestatus", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("episodeppflag", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("episodediagcodes", adVarChar, adParamInput, 255, vbNullString)
      .Parameters.Append .CreateParameter("episodeid", adInteger, adParamOutput, 4)
   End With
   
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8SiteAdoCmdObject(ByVal strDbConn As String, _
                                    ByVal lngSessionID As Long, _
                                    ByRef adoSiteCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8SiteAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoSiteCmd = New ADODB.Command
   
   With adoSiteCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8SiteInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("sitenumber", adInteger, adParamInput, 4, 0)
   End With
      
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub BuildV8SupplierAdoCmdObject(ByVal strDbConn As String, _
                                        ByVal lngSessionID As Long, _
                                        ByVal lngLocationID_Site As Long, _
                                        ByVal lngLocationID_Parent As Long, _
                                        ByRef adoPatCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8SupplierAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoPatCmd = New ADODB.Command
   
   With adoPatCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8SupplierInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("locationid_parent", adInteger, adParamInput, 4, lngLocationID_Parent)
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 5, vbNullString)
      .Parameters.Append .CreateParameter("contractaddress", adVarChar, adParamInput, 100, vbNullString)
      .Parameters.Append .CreateParameter("supaddress", adVarChar, adParamInput, 100, vbNullString)
      .Parameters.Append .CreateParameter("invaddress", adVarChar, adParamInput, 100, vbNullString)
      .Parameters.Append .CreateParameter("conttelno", adVarChar, adParamInput, 14, vbNullString)
      .Parameters.Append .CreateParameter("suptelno", adVarChar, adParamInput, 14, vbNullString)
      .Parameters.Append .CreateParameter("invtelno", adVarChar, adParamInput, 14, Null)
      .Parameters.Append .CreateParameter("discountdesc", adVarChar, adParamInput, 70, 0)
      .Parameters.Append .CreateParameter("discountval", adVarChar, adParamInput, 9, 0)
      .Parameters.Append .CreateParameter("method", adVarChar, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("ordmessage", adVarChar, adParamInput, 50, vbNullString)
      .Parameters.Append .CreateParameter("avleadtime", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("contfaxno", adVarChar, adParamInput, 14, vbNullString)
      .Parameters.Append .CreateParameter("supfaxno", adVarChar, adParamInput, 14, vbNullString)
      .Parameters.Append .CreateParameter("invfaxno", adVarChar, adParamInput, 13, vbNullString)
      .Parameters.Append .CreateParameter("name", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("ptn", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("psis", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("fullname", adVarChar, adParamInput, 35, vbNullString)
      .Parameters.Append .CreateParameter("discountbelow", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("discountabove", adVarChar, adParamInput, 4, vbNullString)
      .Parameters.Append .CreateParameter("icode", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("costcentre", adVarChar, adParamInput, 15, vbNullString)
      .Parameters.Append .CreateParameter("printdelnote", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("printpickticket", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("suppliertype", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("orderoutput", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("receivegoods", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("topupinterval", adVarChar, adParamInput, 2, vbNullString)
      .Parameters.Append .CreateParameter("atcsupplied", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("topupdate", adVarChar, adParamInput, 8, vbNullString)
      .Parameters.Append .CreateParameter("inuse", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("wardcode", adVarChar, adParamInput, 5, vbNullString)
      .Parameters.Append .CreateParameter("oncost", adVarChar, adParamInput, 3, vbNullString)
      .Parameters.Append .CreateParameter("inpatientdirections", adVarChar, adParamInput, 1, 0)
      .Parameters.Append .CreateParameter("adhocdelnote", adVarChar, adParamInput, 1, vbNullString)
      .Parameters.Append .CreateParameter("wsupplierid", adInteger, adParamOutput, 4)
   End With
      
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildV8OrdersAdoCmdObject(ByVal strDbConn As String, _
                                      ByVal lngSessionID As Long, _
                                      ByVal lngLocationID_Site As Long, _
                                      ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildV8OrdersAdoCmdObject"

Dim udtError As udtErrorState

Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WOrderInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("revisionlevel", adVarChar, adParamInput, 2, "")
      .Parameters.Append .CreateParameter("code", adVarChar, adParamInput, 7, "")
      .Parameters.Append .CreateParameter("outstanding", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("orddate", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("ordtime", adVarChar, adParamInput, 6, "")
      .Parameters.Append .CreateParameter("loccode", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("supcode", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("status", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("numprefix", adVarChar, adParamInput, 6, "")
      .Parameters.Append .CreateParameter("num", adVarChar, adParamInput, 4, "")
      .Parameters.Append .CreateParameter("cost", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("pickno", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("received", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("recdate", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("rectime", adVarChar, adParamInput, 6, "")
      .Parameters.Append .CreateParameter("invnum", adVarChar, adParamInput, 12, "")
      .Parameters.Append .CreateParameter("paydate", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("qtyordered", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("urgency", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("tofollow", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("internalsiteno", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("internalmethod", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("suppliertype", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("convfact", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("issueunits", adVarChar, adParamInput, 5, "")
      .Parameters.Append .CreateParameter("stocked", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("description", adVarChar, adParamInput, 56, "")
      .Parameters.Append .CreateParameter("pflag", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("createduser", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("custordno", adVarChar, adParamInput, 12, "")
      .Parameters.Append .CreateParameter("vatamount", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("vatratecode", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("vatratepct", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("vatinclusive", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("indispute", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("indisputeuser", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("shelfprinted", adVarChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("worderid", adInteger, adParamOutput, 4, 0)
   End With
      
Cleanup:

   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub ConvertEpisodes(ByVal intSiteNumber As Integer, _
                            ByVal strDataDrive As String, _
                            ByVal strRecno As String, _
                            ByVal lngEntityID As Long, _
                            ByRef rsEp As DAO.Recordset, _
                            ByRef adoEpCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertEpisodes"

Dim udtError As udtErrorState
                               
Dim lngSuccess As Long

Dim strSiteNumber As String

   On Error GoTo ErrorHandler

   If Not rsEp Is Nothing Then
      
      If Not rsEp.EOF Then rsEp.MoveFirst
      
      On Error GoTo DataError
      
      Do While Not rsEp.EOF
         adoEpCmd.Parameters("idnum").value = GetField(rsEp.fields("idnum"))
         adoEpCmd.Parameters("entityid").value = lngEntityID
         adoEpCmd.Parameters("patrecno").value = GetField(rsEp.fields("patrecno"))
         adoEpCmd.Parameters("createddate").value = CDate(GetField(rsEp.fields("createddate")))
         adoEpCmd.Parameters("createduserid").value = GetField(rsEp.fields("createduserid"))
         adoEpCmd.Parameters("createdterminal").value = GetField(rsEp.fields("createdterminal"))
         adoEpCmd.Parameters("updateddate").value = CDate(GetField(rsEp.fields("updateddate")))
         adoEpCmd.Parameters("updateduserid").value = GetField(rsEp.fields("updateduserid"))
         adoEpCmd.Parameters("updatedterminal").value = GetField(rsEp.fields("updatedterminal"))
         adoEpCmd.Parameters("class").value = GetField(rsEp.fields("class"))
         adoEpCmd.Parameters("episodenumber").value = GetField(rsEp.fields("episodenum"))
         adoEpCmd.Parameters("episodeactive").value = GetField(rsEp.fields("episodeactive"))
         adoEpCmd.Parameters("facilityid").value = GetField(rsEp.fields("facilityid"))
         adoEpCmd.Parameters("episodeward").value = GetField(rsEp.fields("episodeward"))
         adoEpCmd.Parameters("episoderoom").value = GetField(rsEp.fields("episoderoom"))
         adoEpCmd.Parameters("attendingdr").value = GetField(rsEp.fields("attendingdr"))
         adoEpCmd.Parameters("admitdt").value = MakeDate(GetField(rsEp.fields("admitdate")), GetField(rsEp.fields("admittime")))
         adoEpCmd.Parameters("dischargedt").value = MakeDate(GetField(rsEp.fields("dischdate")), GetField(rsEp.fields("dischtime")))
         adoEpCmd.Parameters("episodecons").value = GetField(rsEp.fields("episodecons"))
         adoEpCmd.Parameters("episodespec").value = GetField(rsEp.fields("episodespeciality"))
         adoEpCmd.Parameters("episodeweight").value = GetField(rsEp.fields("episodeweight"))
         adoEpCmd.Parameters("episodeheight").value = GetField(rsEp.fields("episodeheight"))
         adoEpCmd.Parameters("episodegp").value = GetField(rsEp.fields("episodegp"))
         adoEpCmd.Parameters("episodestatus").value = GetField(rsEp.fields("episodestatus"))
         adoEpCmd.Parameters("episodeppflag").value = GetField(rsEp.fields("episodeppflag"))
         adoEpCmd.Parameters("episodediagcodes").value = GetField(rsEp.fields("episodediagcodes"))
         
         adoEpCmd.Execute lngSuccess, , adExecuteNoRecords
               
DataResume:

         If IsNull(adoEpCmd.Parameters("episodeid").value) Then adoEpCmd.Parameters("episodeid").value = -1
         If IsEmpty(adoEpCmd.Parameters("episodeid").value) Then adoEpCmd.Parameters("episodeid").value = 0
         
         If adoEpCmd.Parameters("episodeid").value <= 0 Then
            strSiteNumber = Format$(intSiteNumber)
            LogConversionError udtError, _
                               strSiteNumber, _
                               adoEpCmd.ActiveConnection.ConnectionString, _
                               BuildV8FilePath(strDataDrive, ePatdata, strSiteNumber, "patepisd.mdb"), _
                               GetField(rsEp.fields("idnum"))
         End If
         
         rsEp.MoveNext
      Loop
   End If

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Private Sub ConvertExtraSupplierData(ByVal lngSessionID As Long, _
                                     ByVal strSiteNumber As String, _
                                     ByVal strDataDrive As String, _
                                     ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Oct05 EAC  Written
'  11Nov14 XN   53175 Better error if notes length is too long
'
'----------------------------------------------------------------------------------
Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertExtraSupplierData"

Dim udtError As udtErrorState

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8ExtraSupplierDataAdoCmdObject strDbConn, _
                                        lngSessionID, _
                                        lngLocationID_Site, _
                                        adoCmd
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM ExtraSupplierData", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM ExtraSupplierData", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            On Error GoTo DataError
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " + FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            Do While Not daoRs.EOF
            
               lngFilePosn = lngFilePosn + 1
               
               If (frmMain.UpdateProgress) Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               .Parameters("wextrasupplierdataid").value = Null      ' 11Nov14 XN 53175 clear id incase get length error
               
               ' 11Nov14 XN 53175 Added length validation
               If Len(daoRs.fields("notes").value) > 1024 Then
                  RaiseError erInputStringExceedsWidth, " ExtraSupplierData.notes for site " + strSiteNumber + " exceeds 1024 characters"
               ElseIf Len(daoRs.fields("currentcontractdata").value) > 1024 Then
                  RaiseError erInputStringExceedsWidth, " ExtraSupplierData.currentcontractdata for site " + strSiteNumber + " exceeds 1024 characters"
               ElseIf Len(daoRs.fields("newcontractdata").value) > 1024 Then
                  RaiseError erInputStringExceedsWidth, " ExtraSupplierData.newcontractdata for site " + strSiteNumber + " exceeds 1024 characters"
               Else
                  .Parameters("supcode").value = GetField(daoRs.fields("supcode"))
                  .Parameters("currentcontractdata").value = GetField(daoRs.fields("currentcontractdata"))
                  .Parameters("newcontractdata").value = GetField(daoRs.fields("newcontractdata"))
                  .Parameters("dateofchange").value = GetField(daoRs.fields("dateofchange"))
                  .Parameters("contactname1").value = GetField(daoRs.fields("contactname1"))
                  .Parameters("contactname2").value = GetField(daoRs.fields("contactname2"))
                  .Parameters("notes").value = GetField(daoRs.fields("notes"))

                  .Execute , , adExecuteNoRecords
               End If
               
DataResume:
      
               If IsNull(.Parameters("wextrasupplierdataid").value) Then .Parameters("wextrasupplierdataid").value = -1
               If IsEmpty(.Parameters("wextrasupplierdataid").value) Then .Parameters("wextrasupplierdataid").value = 0
               
               If .Parameters("wextrasupplierdataid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   Set daoRs = Nothing
   daoDb.Close
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub ConvertGPFile(ByVal lngSessionID As Long, _
                          ByVal strSiteNumber As String, _
                          ByVal strDataDrive As String, _
                          ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const GP_FILE_NAME = "gpcode.dat"
Const SUB_NAME = "ConvertGPFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim objFSO As Scripting.FileSystemObject
Dim objFile As Scripting.TextStream

Dim intInuse As Integer
Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long
Dim lngSepPosn As Long

Dim strCode As String
Dim strDesc As String
Dim strLine As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             GP_FILE_NAME)
                                    
   
   Set objFSO = New Scripting.FileSystemObject
   
   If objFSO.fileexists(strFile) Then
   
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              intSiteNumber)
      BuildV8GpAdoCmdObject strDbConn, _
                            lngSessionID, _
                            lngLocationID_Site, _
                            adoCmd
      
      Set objFile = objFSO.OpenTextFile(strFile, _
                                        ForReading)
      
      If Not objFile.AtEndOfStream Then
         
         strLine = objFile.ReadLine
         lngMaxFilePosn = Val(strLine)
         
         If lngMaxFilePosn > 0 Then
         
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & GP_FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            For lngFilePosn = 0 To lngMaxFilePosn
            
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               If lngFilePosn = 0 Then
                  strCode = "XXXX"
                  strDesc = "Unknown GP Code"
                  intInuse = 1
               Else
                  If objFile.AtEndOfStream Then Exit For
                  
                  strLine = objFile.ReadLine
                  strLine = Mid$(strLine, 2, Len(strLine) - 2)
                  lngSepPosn = InStr(1, strLine, Chr$(34) & "," & Chr$(34))
                  strCode = Left$(strLine, lngSepPosn - 1)
                  strDesc = Mid$(strLine, lngSepPosn + 3)
   
                  intInuse = 1
                  If InStr(1, strDesc, "#") > 0 Then
                     intInuse = 0
                     strDesc = Replace(strDesc, "#", vbNullString)
                  End If
               End If
               
               adoCmd.Parameters("code").value = Trim$(strCode)
               adoCmd.Parameters("description").value = Trim$(strDesc)
               adoCmd.Parameters("inuse").value = intInuse
               
               adoCmd.Execute , , adExecuteNoRecords
               
DataResume:

               If IsNull(adoCmd.Parameters("entityid").value) Then adoCmd.Parameters("entityid").value = -1
               If IsEmpty(adoCmd.Parameters("entityid").value) Then adoCmd.Parameters("entityid").value = 0
               
               If adoCmd.Parameters("entityid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
            
            Next
         End If
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   objFile.Close
   Set objFile = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub
Private Sub ConvertPatdataReadptrFiles(ByVal lngSessionID As Long, _
                                       ByVal strDbConn As String, _
                                       ByVal strDataDrive As String, _
                                       ByVal strPatdataSiteNumber As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Nov05 EAC  Written
'  15Oct09 EAC  Corrected "BNV.V75" to "BNM.V75" in the DISPDATA_READPTR_FILES constant.
'
'----------------------------------------------------------------------------------
Const PATDATA_READPTR_FILES = "RXID.DAT"
Const SUB_NAME = "ConvertPatdataReadptrFiles"

Dim adoCmd As ADODB.Command

Dim udtError As udtErrorState
                               
Dim lngLocationID_Site As Long
Dim lngLoop As Long

Dim astrFiles() As String

Dim strCategory As String
Dim strFileName As String

   On Error GoTo ErrorHandler
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           Val(strPatdataSiteNumber))
                                           
   'build an ADO command unit to update the wReadPtr table
   BuildV8ReadptrAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoCmd

   'Process the dispdata read pointer files
   astrFiles = Split(PATDATA_READPTR_FILES, ",")
   
   For lngLoop = LBound(astrFiles) To UBound(astrFiles)
      strFileName = BuildV8FilePath(strDataDrive, _
                                    ePatdata, _
                                    strPatdataSiteNumber, _
                                    astrFiles(lngLoop))
                                    
      If Len(Dir$(strFileName)) > 0 Then
         strCategory = CreateCategory(ePatdata, _
                                      astrFiles(lngLoop), _
                                      False)
                                      
         ProcessReadptrFile strPatdataSiteNumber, _
                            strDbConn, _
                            strFileName, _
                            strCategory, _
                            adoCmd
      End If
   Next
 
Cleanup:

   On Error Resume Next
   If Not adoCmd.ActiveConnection Is Nothing Then
      adoCmd.ActiveConnection.Close
      Set adoCmd.ActiveConnection = Nothing
   End If
   Set adoCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

'Private Function ConvertRxIDXFile(ByVal lngSessionID As Long, _
'                                  ByVal strSiteNumber As String, _
'                                  ByVal strDataDrive As String, _
'                                  ByVal strDbConn As String) As Boolean
''----------------------------------------------------------------------------------
''
'' Purpose:
''
'' Inputs:
''     lngSessionID        :  Standard sessionid
''
'' Outputs:
''
''     returns an errors as <BrokenRules/> XML string
''
'' Modification History:
''  10Jan06 EAC  Written
''
''----------------------------------------------------------------------------------
'Const MIN_LINE_LENGTH = 7
'Const PATIENT_ID_LENGTH = 10
'Const RX_IDX_FILE = "RX.IDX"
'Const RX_LOG_LENGTH = 4
'Const SUB_NAME = "ConvertRxIDXFile"
'
'Dim adoCmd As ADODB.Command
'Dim objIndexing As ASCIndexingV1.Indexing
'
'Dim udtError As udtErrorState
'
'Dim boolOpen As Boolean
'
'Dim intDel As Integer
'Dim intLineLen As Integer
'Dim intSiteNumber As Integer
'
'Dim lngFilePosition As Long
'Dim lngLocationID_Site As Long
'Dim lngLoop As Long
'Dim lngNumOfEntries As Long
'Dim lngVector As Long
'
'Dim strExtraInfo As String
'Dim strFile As String
'Dim strIdxEntry As String * 14
'Dim strLine As String
'Dim strPatidIdx As String * 10
'Dim strRxFileName As String * 4
'
'
'   On Error GoTo ErrorHandler
'
'   ConvertRxIDXFile = False
'
'   strExtraInfo = "Building file path..."
'   strFile = BuildV8FilePath(strDataDrive, _
'                             ePatdata, _
'                             strSiteNumber, _
'                             RX_IDX_FILE)
'
'   intSiteNumber = Val(strSiteNumber)
'
'   strExtraInfo = "Finding the site's LocationID"
'   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
'                                           strDbConn, _
'                                           intSiteNumber)
'
'   BuildV8RxIdxAdoCmdObject strDbConn, _
'                            lngSessionID, _
'                            lngLocationID_Site, _
'                            adoCmd
'
'   strExtraInfo = "Creating ASCIndexingV1.Indexing object..."
'   Set objIndexing = New ASCIndexingV1.Indexing
'
'   strExtraInfo = "Opening file " & strFile & "..."
'   boolOpen = objIndexing.OpenIndex(strFile)
'
'   If boolOpen Then
'      strExtraInfo = "Reading index length from " & strFile & "..."
'      objIndexing.getidxline 1, MIN_LINE_LENGTH + 2, strIdxEntry, lngVector, intDel, strFile
'      intLineLen = Val(strIdxEntry) + MIN_LINE_LENGTH
'
'      strExtraInfo = "Reading number of entries in " & strFile & "..."
'      objIndexing.getidxline 1, intLineLen, strIdxEntry, lngNumOfEntries, intDel, strFile
'
'      On Error GoTo DataError
'
'      For lngLoop = 1 To lngNumOfEntries
'         strLine = Format$(lngLoop)
'         strExtraInfo = "Reading line " & strLine & " from " & strFile
'         objIndexing.getidxline 2 + lngLoop, intLineLen, strIdxEntry, lngVector, intDel, strFile
'
'         strExtraInfo = "Processing line " & strLine & " - " & strIdxEntry
'         strPatidIdx = Left$(strIdxEntry, PATIENT_ID_LENGTH)
'         strRxFileName = Right$(strIdxEntry, RX_LOG_LENGTH)
'
'         With adoCmd
'
'            .Parameters("V8PatientId").value = strPatidIdx
'            .Parameters("RxFileName").value = strRxFileName
'            .Parameters("RxPosition").value = lngVector
'
'            .Execute
'
'DataResume:
'
'            If IsNull(.Parameters("V8RxIdxID").value) Then .Parameters("V8RxIdxID").value = -1
'            If IsEmpty(.Parameters("V8RxIdxID").value) Then .Parameters("V8RxIdxID").value = 0
'
'            If .Parameters("V8RxIdxID").value <= 0 Then
'               LogConversionError udtError, _
'                                  strSiteNumber, _
'                                  strDbConn, _
'                                  strFile, _
'                                  lngLoop + 2
'
'            End If
'         End With
'
'         ConvertRxIDXFile = True
'      Next
'
'   End If
'
'Cleanup:
'
'   On Error Resume Next
'   If Not objIndexing Is Nothing Then
'      objIndexing.CloseIndex
'      Set objIndexing = Nothing
'   End If
'
'   If Not adoCmd Is Nothing Then
'      adoCmd.ActiveConnection.Close
'      Set adoCmd.ActiveConnection = Nothing
'      Set adoCmd = Nothing
'   End If
'
'   On Error GoTo 0
'   BubbleOnError udtError
'
'Exit Function
'
'DataError:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume DataResume
'
'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
'   Resume Cleanup
'
'End Function

Private Sub ConvertDispdataReadptrFiles(ByVal lngSessionID As Long, _
                                        ByVal strDbConn As String, _
                                        ByVal strDataDrive As String, _
                                        ByVal strDispdataSiteNumber As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Nov05 EAC  Written
'  15Oct09 EAC  Corrected "BNV.V75" to "BNM.V75" in the DISPDATA_READPTR_FILES constant.
'
'----------------------------------------------------------------------------------
Const DISPDATA_READPTR_FILES = "ORDERNO.DAT,REQNO.DAT,DELNO.DAT,RETNO.DAT,DISPNOTE.DAT,ADJUST.DAT,BNM.V75,CIVASBAT.DAT"
Const SUB_NAME = "ConvertDispdataReadptrFiles"

Dim adoCmd As ADODB.Command

Dim udtError As udtErrorState
                               
Dim lngLocationID_Site As Long
Dim lngLoop As Long

Dim astrFiles() As String

Dim strCategory As String
Dim strFileName As String

   On Error GoTo ErrorHandler
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           Val(strDispdataSiteNumber))
                                           
   'build an ADO command unit to update the wReadPtr table
   BuildV8ReadptrAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoCmd

   'Process the dispdata read pointer files
   astrFiles = Split(DISPDATA_READPTR_FILES, ",")
   
   For lngLoop = LBound(astrFiles) To UBound(astrFiles)
      strFileName = BuildV8FilePath(strDataDrive, _
                                    eDispdata, _
                                    strDispdataSiteNumber, _
                                    astrFiles(lngLoop))
                                    
      If Len(Dir$(strFileName)) > 0 Then
         strCategory = CreateCategory(eDispdata, _
                                      astrFiles(lngLoop), _
                                      False)
                                      
         ProcessReadptrFile strDispdataSiteNumber, _
                            strDbConn, _
                            strFileName, _
                            strCategory, _
                            adoCmd
      End If
   Next

Cleanup:

   On Error Resume Next
   If Not adoCmd.ActiveConnection Is Nothing Then
      adoCmd.ActiveConnection.Close
      Set adoCmd.ActiveConnection = Nothing
   End If
   Set adoCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Private Sub ConvertStorevatDefFile(ByVal lngSessionID As Long, _
                                   ByVal strSiteNumber As String, _
                                   ByVal strDataDrive As String, _
                                   ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Oct05 EAC  Written
'
'----------------------------------------------------------------------------------
Const Category = "d|WorkingDefaults"
Const KEYNAMES = "TransLogVAT|OrderLogVAT|Highfact|Lowfact|entercostonreceipt|tofollow|VAT(0)|VAT(1)|VAT(2)|" & _
                 "VAT(3)|VAT(4)|VAT(5)|VAT(6)|VAT(7)|VAT(8)|VAT(9)|UtilOrdNum|UtilSupplier|UtilReasonNew|UtilReasonMod"
Const STOREVAT_DEF_FILENAME = "STOREVAT.DEF"
Const SUB_NAME = "ConvertStorevatDefFile"

Dim udtError As udtErrorState
                                
Dim intCount As Integer
Dim intHdl As Integer

Dim astrKeyNames() As String
Dim strFile As String
Dim strLine As String

   On Error GoTo ErrorHandler

   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             STOREVAT_DEF_FILENAME)

   astrKeyNames = Split(KEYNAMES, "|")
   
   intHdl = FreeFile()
   Open strFile For Input Lock Read Write As intHdl
   
   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & STOREVAT_DEF_FILENAME, _
                            0
                            
   On Error GoTo DataError
   
   Do While Not EOF(intHdl)
      
      Line Input #intHdl, strLine
                        
      With adoCmd
         .Parameters("category").value = Category
         .Parameters("section").value = vbNullString
         .Parameters("key").value = astrKeyNames(intCount)
         .Parameters("value").value = CreateConfigValue(strLine)
         
         .Execute , , adExecuteNoRecords
         
DataResume:
         If IsNull(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = -1
         If IsEmpty(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = 0
         
         If adoCmd.Parameters("wconfigurationid").value <= 0 Then
            LogConversionError udtError, _
                               strSiteNumber, _
                               adoCmd.ActiveConnection.ConnectionString, _
                               strFile, _
                               intCount
         End If
         
         DoEvents
         
      End With
   
      intCount = intCount + 1
   Loop
   
Cleanup:
   
   On Error Resume Next
   frmProgress.ProgressHide
   
   Close #intHdl
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Private Sub ConvertOrderDatFile(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Oct05 EAC  Written
'  08Feb10 EAC  F0075670 - Removed lines that stopped emtpy lines being processed.
'
'----------------------------------------------------------------------------------
Const Category = "d|WorkingDefaults"
Const KEYNAMES = "preprint|ordnumprefix|ownname|overdue|ordmessage|ordcontact|maxnumoflines|" & _
                 "tp|picknumoflines|delreceipt|delreconcile|FullPageCS|NSVcarriage|NSVdiscount|AskBatchNum|" & _
                 "Delrequis|OrdPrintPrice|OrdPrintLin|ProgressBarScale|PrintToScreen|PrintStockCost|" & _
                 "PrintCanceledOrder|PrintInPacks|AdjCostCentre|WSStores|NSVReconciliation|EOPMargin"
Const ORDER_DAT_FILENAME = "ORDER.DAT"
Const SUB_NAME = "ConvertOrderDatFile"

Dim udtError As udtErrorState
                                
Dim intCount As Integer
Dim intHdl As Integer

Dim astrKeyNames() As String
Dim strFile As String
Dim strLine As String

   On Error GoTo ErrorHandler

   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             ORDER_DAT_FILENAME)

   astrKeyNames = Split(KEYNAMES, "|")
   
   intHdl = FreeFile()
   Open strFile For Input As intHdl Len = 256
   
   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & ORDER_DAT_FILENAME, _
                            0
   On Error GoTo DataError
   
   Do While Not EOF(intHdl)
      
      Input #intHdl, strLine
      
      If (intCount <= UBound(astrKeyNames)) Then
               
         With adoCmd
            .Parameters("category").value = Category
            .Parameters("section").value = vbNullString
            .Parameters("key").value = astrKeyNames(intCount)
            .Parameters("value").value = CreateConfigValue(strLine)
            
            .Execute , , adExecuteNoRecords
            
DataResume:
            If IsNull(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = -1
            If IsEmpty(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = 0
            
            If adoCmd.Parameters("wconfigurationid").value <= 0 Then
               LogConversionError udtError, _
                                  strSiteNumber, _
                                  adoCmd.ActiveConnection.ConnectionString, _
                                  strFile, _
                                  intCount
            End If
            
            DoEvents
                     
         End With
         
         intCount = intCount + 1
      End If
      
   Loop
   
Cleanup:
   
   On Error Resume Next
   frmProgress.ProgressHide
   
   Close #intHdl
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Private Sub ConvertOrderFile(ByVal strDataDrive As String, _
                             ByVal strSiteNumber As String, _
                             ByVal strDbConn As String, _
                             ByVal strOrderFileName As String, _
                             ByVal strSpName As String, _
                             ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertOrderFile"

Dim udtError As udtErrorState
Dim udtOrder As orderstruct

Dim intChan As Integer

Dim lngFilePosn As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String



   On Error GoTo ErrorHandler

   adoCmd.CommandText = strSpName
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             strOrderFileName)
                                       
   lngMaxFilePosn = ReadFilePointer(strFile)

   intChan = FreeFile()
   Open strFile For Binary Access Read Lock Read Write As intChan

   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " + strOrderFileName, _
                            lngMaxFilePosn
                            
   frmMain.StartProgressTimer
   
   With adoCmd
   
      On Error GoTo DataError
      For lngFilePosn = 2 To lngMaxFilePosn
      
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePosn
            frmMain.StartProgressTimer
         End If
         
         udtOrder = GetOrder(intChan, _
                             lngFilePosn)
                                 
                                 
         .Parameters("revisionlevel").value = udtOrder.revisionlevel
         .Parameters("code").value = udtOrder.code
         .Parameters("outstanding").value = udtOrder.outstanding
         .Parameters("orddate").value = udtOrder.orddate
         .Parameters("ordtime").value = udtOrder.ordtime
         .Parameters("loccode").value = udtOrder.loccode
         .Parameters("supcode").value = udtOrder.supcode
         .Parameters("status").value = udtOrder.status
         .Parameters("numprefix").value = udtOrder.numprefix
         .Parameters("num").value = udtOrder.num
         .Parameters("cost").value = udtOrder.cost
         .Parameters("pickno").value = udtOrder.pickno
         .Parameters("received").value = udtOrder.received
         .Parameters("recdate").value = udtOrder.recdate
         .Parameters("rectime").value = udtOrder.rectime
         .Parameters("invnum").value = udtOrder.invnum
         .Parameters("paydate").value = udtOrder.paydate
         .Parameters("qtyordered").value = udtOrder.qtyordered
         .Parameters("urgency").value = udtOrder.urgency
         .Parameters("tofollow").value = udtOrder.tofollow
         .Parameters("internalsiteno").value = udtOrder.internalsiteno
         .Parameters("internalmethod").value = udtOrder.internalmethod
         .Parameters("suppliertype").value = udtOrder.suppliertype
         .Parameters("convfact").value = udtOrder.convfact
         .Parameters("issueunits").value = udtOrder.IssueUnits
         .Parameters("stocked").value = udtOrder.Stocked
         .Parameters("description").value = udtOrder.Description
         .Parameters("pflag").value = udtOrder.pflag
         .Parameters("createduser").value = udtOrder.CreatedUser
         .Parameters("custordno").value = udtOrder.custordno
         .Parameters("vatamount").value = udtOrder.VATAmount
         .Parameters("vatratecode").value = udtOrder.VATRateCode
         .Parameters("vatratepct").value = udtOrder.VATRatePCT
         .Parameters("vatinclusive").value = udtOrder.VATInclusive
         .Parameters("indispute").value = udtOrder.Indispute
         .Parameters("indisputeuser").value = udtOrder.IndisputeUser
         .Parameters("shelfprinted").value = udtOrder.ShelfPrinted
         
         .Execute , , adExecuteNoRecords
         
DataResume:

         If IsNull(.Parameters("worderid").value) Then .Parameters("worderid").value = -1
         If IsEmpty(.Parameters("worderid").value) Then .Parameters("worderid").value = 0
         
         If .Parameters("worderid").value <= 0 Then
            LogConversionError udtError, _
                               strSiteNumber, _
                               strDbConn, _
                               strFile, _
                               lngFilePosn
         End If
         
         DoEvents
      Next
   End With

   

Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   Close #intChan

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub ConvertWardSpecFile(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "wardspec.dat"
Const SUB_NAME = "ConvertWardSpecFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim objFSO As Scripting.FileSystemObject
Dim objFile As Scripting.TextStream

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long
Dim lngSepPosn As Long

Dim strWard As String
Dim strSpec As String
Dim strLine As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   Set objFSO = New Scripting.FileSystemObject
   
   If objFSO.fileexists(strFile) Then
   
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              intSiteNumber)
                                              
      BuildV8WardSpecAdoCmdObject strDbConn, _
                                  lngSessionID, _
                                  lngLocationID_Site, _
                                  adoCmd
      
      Set objFile = objFSO.OpenTextFile(strFile, _
                                        ForReading)
      
      If Not objFile.AtEndOfStream Then
         
         strLine = objFile.ReadLine
         lngMaxFilePosn = Val(strLine)
         
         If lngMaxFilePosn > 0 Then
         
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            For lngFilePosn = 1 To lngMaxFilePosn
            
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               If objFile.AtEndOfStream Then Exit For
               
               strLine = objFile.ReadLine
               strLine = Mid$(strLine, 2, Len(strLine) - 2)
               lngSepPosn = InStr(1, strLine, Chr$(34) & "," & Chr$(34))
               strWard = Left$(strLine, lngSepPosn - 1)
               strSpec = Mid$(strLine, lngSepPosn + 3)

               adoCmd.Parameters("ward").value = strWard
               adoCmd.Parameters("specialty").value = strSpec
               
               adoCmd.Execute , , adExecuteNoRecords
               
DataResume:

               If IsNull(adoCmd.Parameters("wwardlinkspecialtyid").value) Then adoCmd.Parameters("wwardlinkspecialtyid").value = -1
               If IsEmpty(adoCmd.Parameters("wwardlinkspecialtyid").value) Then adoCmd.Parameters("wwardlinkspecialtyid").value = 0
               
               If adoCmd.Parameters("wwardlinkspecialtyid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               DoEvents
            
            Next
         End If
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   objFile.Close
   Set objFile = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub
Private Sub ConvertConsSpecFile(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Dec05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "consspec.dat"
Const SUB_NAME = "ConvertConsSpecFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim objFSO As Scripting.FileSystemObject
Dim objFile As Scripting.TextStream

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long
Dim lngSepPosn As Long

Dim astrSpecialties() As String
Dim strConsCode As String
Dim strSpec As String
Dim strLine As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   Set objFSO = New Scripting.FileSystemObject
   
   If objFSO.fileexists(strFile) Then
   
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              intSiteNumber)
                                              
      BuildV8ConsSpecAdoCmdObject strDbConn, _
                                  lngSessionID, _
                                  lngLocationID_Site, _
                                  adoCmd
      
      Set objFile = objFSO.OpenTextFile(strFile, _
                                        ForReading)
      
      If Not objFile.AtEndOfStream Then
         
         strLine = objFile.ReadLine
         lngMaxFilePosn = Val(strLine)
         
         If lngMaxFilePosn > 0 Then
         
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            On Error GoTo DataError
            
            For lngFilePosn = 1 To lngMaxFilePosn
            
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  
                  frmMain.StartProgressTimer
               End If
               
               If objFile.AtEndOfStream Then Exit For
               
               strLine = objFile.ReadLine
               strLine = Mid$(strLine, 2, Len(strLine) - 2)
               lngSepPosn = InStr(1, strLine, Chr$(34) & "," & Chr$(34))
               strConsCode = Left$(strLine, lngSepPosn - 1)
               strSpec = Mid$(strLine, lngSepPosn + 3)

               astrSpecialties = Split(strSpec, ",")
               For lngLoop = LBound(astrSpecialties) To UBound(astrSpecialties)
                  adoCmd.Parameters("conscode").value = strConsCode
                  adoCmd.Parameters("specialty").value = astrSpecialties(lngLoop)
                  
                  adoCmd.Execute , , adExecuteNoRecords
                  
DataResume:
   
                  DoEvents
               Next
            
            Next
         End If
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   objFile.Close
   Set objFile = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   LogConversionError udtError, _
                      strSiteNumber, _
                      strDbConn, _
                      strFile, _
                      lngFilePosn
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertDirectionFile(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "direct.v6"
Const SUB_NAME = "ConvertDirectionFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim udtDir As directstruct

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngFound As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long
   
Dim strDSS As String
Dim strFile As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8DirectionAdoCmdObject strDbConn, _
                                lngSessionID, _
                                lngLocationID_Site, _
                                adoCmd
   
   lngMaxFilePosn = ReadFilePointer(strFile)
         
   If lngMaxFilePosn > 1 Then
   
      frmProgress.ShowProgress strSiteNumber, _
                               "Processing: " & FILE_NAME, _
                               lngMaxFilePosn
                               
      frmMain.StartProgressTimer
      
      On Error GoTo DataError
      
      For lngFilePosn = 2 To lngMaxFilePosn
      
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePosn
            
            frmMain.StartProgressTimer
         End If
         
         udtDir = getdir(strFile, _
                         lngFilePosn, _
                         lngFound)
      
         If lngFound > 0 Then
            With adoCmd.Parameters
               .item("code").value = udtDir.code
               .item("route").value = udtDir.route
               .item("equaldose").value = udtDir.EqualDose
               .item("equalinterval").value = udtDir.EqualInterval
               .item("timeunits").value = udtDir.TimeUnits
               .item("repeatinterval").value = udtDir.repeatinterval
               .item("repeatunits").value = udtDir.repeatunits
               .item("courselength").value = udtDir.CourseLength
               .item("courseunits").value = udtDir.CourseUnits
               .item("abstime").value = udtDir.Abstime
               .item("days").value = udtDir.days
               For lngLoop = 1 To 12
                  .item("dose" & Format$(lngLoop)).value = udtDir.dose(lngLoop)
                  .item("time" & Format$(lngLoop)).value = udtDir.times(lngLoop)
               Next
               .item("deletedby").value = udtDir.DeletedBy
               .item("approvedby").value = udtDir.ApprovedBy
               .item("revisionno").value = udtDir.RevisionNo
               .item("deleted").value = udtDir.deleted
               .item("location").value = udtDir.location
               .item("directs").value = udtDir.directs
               .item("prn").value = udtDir.PRN
               .item("sortcode").value = udtDir.SortCode
               strDSS = udtDir.DSS
               If Len(Trim$(strDSS)) = 0 Then strDSS = "0"
               .item("dss").value = Val(strDSS)
               .item("hideprescriber").value = udtDir.HidePrescriber
               .item("manualqtyentry").value = udtDir.ManualQtyEntry
               .item("statdoseflag").value = udtDir.StatDoseFlag
            End With
         
            adoCmd.Execute , , adExecuteNoRecords
         
DataResume:
                        
            If IsNull(adoCmd.Parameters("wdirectionsid").value) Then adoCmd.Parameters("wdirectionid").value = -1
            If IsEmpty(adoCmd.Parameters("wdirectionsid").value) Then adoCmd.Parameters("wdirectionid").value = 0
            
            If adoCmd.Parameters("wdirectionsid").value <= 0 Then
               LogConversionError udtError, _
                      strSiteNumber, _
                      strDbConn, _
                      strFile, _
                      lngFilePosn
            End If
         End If
      Next
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertLookupFiles(ByVal lngSessionID As Long, _
                               ByVal strDataDrive As String, _
                               ByVal strSiteNumber As String, _
                               ByVal strDbConn As String, _
                               ByVal eLocation As enumV8FileLocation, _
                               ByVal lngLocationID_Site As Long)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertLookupFiles"

Dim udtError As udtErrorState
                              
Dim adoContextCmd As ADODB.Command
Dim adoLookupCmd As ADODB.Command

Dim lngLoop As Long

Dim astrFileSpecs(10) As String

   On Error GoTo ErrorHandler

   BuildV8LookupAdoCmdObject strDbConn, _
                             lngSessionID, _
                             lngLocationID_Site, _
                             adoContextCmd, _
                             adoLookupCmd
                             
   astrFileSpecs(0) = "ETHNCODE.DAT"
   astrFileSpecs(1) = "REASON.DAT"
   astrFileSpecs(2) = "USERMSG.DAT"
   astrFileSpecs(3) = "DIRCTRTE.DAT"
   astrFileSpecs(4) = "LEDGCODE.DAT"
   astrFileSpecs(5) = "FFLABELS.DAT"
   astrFileSpecs(6) = "SPECLTY.DAT"
   astrFileSpecs(7) = "INSTR???.V4"
   astrFileSpecs(8) = "WARN???.V4"
   astrFileSpecs(9) = "INSTR???.DSS"
   astrFileSpecs(10) = "WARN???.DSS"
   
   For lngLoop = LBound(astrFileSpecs) To UBound(astrFileSpecs)
      FindLookupFiles lngSessionID, _
                      strDataDrive, _
                      strSiteNumber, _
                      strDbConn, _
                      eDispdata, _
                      astrFileSpecs(lngLoop), _
                      adoLookupCmd, _
                      adoContextCmd
   Next
   
Cleanup:

      
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub
Private Sub ConvertAscrootConfigurationFiles(ByVal lngSessionID As Long, _
                                             ByVal strDataDrive As String, _
                                             ByVal strDbConn As String, _
                                             ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertAscrootConfigurationFiles"

Dim udtError As udtErrorState
                              
Dim lngLoop As Long

Dim astrFileSpecs(3) As String

   On Error GoTo ErrorHandler

   astrFileSpecs(0) = "dqqw.*"
   astrFileSpecs(1) = "ident.*"
   astrFileSpecs(2) = "securew.*"
   astrFileSpecs(3) = "tpnw.*"
      
   For lngLoop = LBound(astrFileSpecs) To UBound(astrFileSpecs)
      FindConfigFiles lngSessionID, _
                      strDataDrive, _
                      vbNullString, _
                      strDbConn, _
                      eAscroot, _
                      astrFileSpecs(lngLoop), _
                      adoCmd
   Next
   
Cleanup:

      
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertSupplierFile(ByVal lngSessionID As Long, _
                               ByVal strSiteNumber As String, _
                               ByVal strDataDrive As String, _
                               ByVal strDbConn As String, _
                               ByVal lngLocationID_Parent As Long)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "supfile.v5"
Const SUB_NAME = "ConvertSupplierFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

'Dim objV8Sup As V8SupplierDll.V85

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
Dim lclsup As supplierstruct
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strExtraInfo = "BuildingV8FilePath..."
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   strExtraInfo = "Finding Site LocationID..."
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   strExtraInfo = "Building the V8 Supplier ADO command object..."
   BuildV8SupplierAdoCmdObject strDbConn, _
                               lngSessionID, _
                               lngLocationID_Site, _
                               lngLocationID_Parent, _
                               adoCmd
      
   'strExtraInfo = "Creating object 'V8SupplierDll.V85'"
   'Set objV8Sup = New V8SupplierDll.V85
      
   strExtraInfo = "Reading the pointer from file " + strFile
   lngMaxFilePosn = ReadFilePointer(strFile)

   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & FILE_NAME, _
                            lngMaxFilePosn
                            
   frmMain.StartProgressTimer
   
   strExtraInfo = "Processing the file..."
   With adoCmd
   
      On Error GoTo DataError
      For lngFilePosn = 1 To lngMaxFilePosn
      
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePosn
            frmMain.StartProgressTimer
         End If
         
         If lngFilePosn = 1 Then
            lclsup.code = "XXXX"
            lclsup.FullName = "Unknown code"
            lclsup.name = "Unknown code"
            lclsup.suppliertype = "W"
         Else
            'objV8Sup.GetSupplier intSiteNumber, _
            '                     strDataDrive, _
            '                     lngFilePosn
            GetSupplier intSiteNumber, strDataDrive, lngFilePosn, lclsup
         End If
         
         .Parameters("code").value = Trim$(lclsup.code)
         .Parameters("contractaddress").value = lclsup.contractaddress
         .Parameters("supaddress").value = lclsup.supaddress
         .Parameters("invaddress").value = lclsup.invaddress
         .Parameters("conttelno").value = lclsup.conttelno
         .Parameters("suptelno").value = lclsup.suptelno
         .Parameters("invtelno").value = lclsup.invtelno
         .Parameters("discountdesc").value = lclsup.discountdesc
         .Parameters("discountval").value = lclsup.discountval
         .Parameters("method").value = lclsup.Method
         .Parameters("ordmessage").value = lclsup.ordmessage
         .Parameters("avleadtime").value = lclsup.avleadtime
         .Parameters("contfaxno").value = lclsup.contfaxno
         .Parameters("supfaxno").value = lclsup.supfaxno
         .Parameters("invfaxno").value = lclsup.invfaxno
         .Parameters("name").value = lclsup.name
         .Parameters("ptn").value = lclsup.ptn
         .Parameters("psis").value = lclsup.psis
         .Parameters("fullname").value = lclsup.FullName
         .Parameters("discountbelow").value = lclsup.discountbelow
         .Parameters("discountabove").value = lclsup.discountabove
         .Parameters("icode").value = lclsup.icode
         .Parameters("costcentre").value = lclsup.CostCentre
         .Parameters("printdelnote").value = lclsup.PrintDeliveryNote
         .Parameters("printpickticket").value = lclsup.PrintPickTicket
         .Parameters("suppliertype").value = lclsup.suppliertype
         .Parameters("orderoutput").value = lclsup.OrderOutput
         .Parameters("receivegoods").value = lclsup.ReceiveGoods
         .Parameters("topupinterval").value = lclsup.TopupInterval
         .Parameters("atcsupplied").value = lclsup.ATCSupplied
         .Parameters("topupdate").value = lclsup.TopUpDate
         .Parameters("inuse").value = lclsup.InUse
         .Parameters("wardcode").value = lclsup.wardcode
         .Parameters("oncost").value = lclsup.onCost
         .Parameters("inpatientdirections").value = lclsup.InPatientDirections
         .Parameters("adhocdelnote").value = lclsup.AdHocDelNote
         
         .Execute , , adExecuteNoRecords
         
DataResume:

         If IsNull(.Parameters("wsupplierid").value) Then .Parameters("wsupplierid").value = -1
         If IsEmpty(.Parameters("wsupplierid").value) Then .Parameters("wsupplierid").value = 0
         
         If .Parameters("wsupplierid").value <= 0 Then
            LogConversionError udtError, _
                               strSiteNumber, _
                               strDbConn, _
                               strFile, _
                               lngFilePosn
         End If
         
         DoEvents
      Next
   End With
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
                               
End Sub
Private Sub ConvertSupplierProfileMdb(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "supprof.mdb"
Const SUB_NAME = "ConvertSupplierProfileMdb"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8SupProfAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoCmd
      

   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Profile", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM Profile", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               .Parameters("nsvcode").value = GetField(daoRs.fields("NSVCode"))
               .Parameters("supcode").value = GetField(daoRs.fields("SupCode"))
               .Parameters("primarysupplier").value = GetField(daoRs.fields("PrimarySup"))
               .Parameters("cost").value = GetField(daoRs.fields("Cost"))
               .Parameters("contno").value = GetField(daoRs.fields("ContNo"))
               .Parameters("reorderpcksize").value = GetField(daoRs.fields("Reorderpcksize"))
               .Parameters("reorderlvl").value = GetField(daoRs.fields("Reorderlvl"))
               .Parameters("reorderqty").value = GetField(daoRs.fields("Reorderqty"))
               .Parameters("sislistprice").value = GetField(daoRs.fields("SisListPrice"))
               .Parameters("contprice").value = GetField(daoRs.fields("ContPrice"))
               .Parameters("leadtime").value = GetField(daoRs.fields("LeadTime"))
               .Parameters("lastreconcileprice").value = GetField(daoRs.fields("LastReconcilePrice"))
               .Parameters("tradename").value = GetField(daoRs.fields("Tradename"))
               .Parameters("supprefno").value = GetField(daoRs.fields("SuppRefNo"))
               .Parameters("altbarcode").value = GetField(daoRs.fields("AltBarcode"))
               .Parameters("varrate").value = ""
               'VatRate not in every supprof.mdb, so check if it exists
               If daoRs.fields.Count = 16 Then .Parameters("varrate").value = GetField(daoRs.fields("VatRate"))
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wsupplierprofileid").value) Then .Parameters("wsupplierprofileid").value = -1
               If IsEmpty(.Parameters("wsupplierprofileid").value) Then .Parameters("wsupplierprofileid").value = 0
               
               If .Parameters("wsupplierprofileid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertSpecialty(ByVal lngSessionID As Long, _
                             ByVal strSiteNumber As String, _
                             ByVal strDataDrive As String, _
                             ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  26Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "SPECLTY.DAT"
Const SUB_NAME = "ConvertSpecialty"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim objFSO As Scripting.FileSystemObject
Dim objFile As Scripting.TextStream

Dim boolInUse As Boolean

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngMaxFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngSepPosn As Long

Dim strCode As String
Dim strExpn As String
Dim strLine As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   Set objFSO = New Scripting.FileSystemObject
   
   If objFSO.fileexists(strFile) Then
   
      BuildV8SpecialtyAdoCmdObject strDbConn, _
                                   lngSessionID, _
                                   lngLocationID_Site, _
                                   adoCmd
      
      Set objFile = objFSO.OpenTextFile(strFile, _
                                        ForReading)
      
      If Not objFile.AtEndOfStream Then
         
         strLine = objFile.ReadLine
         lngMaxFilePosn = Val(strLine)
         
         If lngMaxFilePosn > 0 Then
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " + FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            For lngFilePosn = 0 To lngMaxFilePosn
            
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               If lngFilePosn = 0 Then
                  strCode = "XXXX"
                  strExpn = "Unknown specialty"
               Else
                  If objFile.AtEndOfStream Then Exit For
                  
                  strLine = objFile.ReadLine
                  
                  strLine = Mid$(strLine, 2, Len(strLine) - 2)
                  lngSepPosn = InStr(1, strLine, Chr$(34) & "," & Chr$(34))
                  
                  strCode = Left$(strLine, lngSepPosn - 1)
                  strExpn = Mid$(strLine, lngSepPosn + 3)
               End If
               
               adoCmd.Parameters("code").value = Trim$(strCode)
               adoCmd.Parameters("description").value = Trim$(strExpn)
               
               adoCmd.Execute , , adExecuteNoRecords
               
DataResume:
               
               If IsNull(adoCmd.Parameters("specialtyid").value) Then adoCmd.Parameters("specialtyid").value = -1
               If IsEmpty(adoCmd.Parameters("specialtyid").value) Then adoCmd.Parameters("specialtyid").value = 0
               
               If adoCmd.Parameters("specialtyid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
            
            Next
         End If
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.Hide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   objFile.Close
   Set objFile = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
                               
End Sub

Private Sub ConvertStockLabelMdb(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  28Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "stcklbls.mdb"
Const SUB_NAME = "ConvertStockLabelMdb"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngLocationID_Site As Long
Dim lngFilePosn As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8StockLabelAdoCmdObject strDbConn, _
                                 lngSessionID, _
                                 lngLocationID_Site, _
                                 adoCmd
      

   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM StockLabels", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM StockLabels", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               .Parameters("id").value = GetField(daoRs.fields("ID"))
               .Parameters("drugcode").value = GetField(daoRs.fields("DrugCode"))
               .Parameters("wardcode").value = GetField(daoRs.fields("WardCode"))
               .Parameters("rtffilename").value = GetField(daoRs.fields("RTFFileName"))
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wstocklabelid").value) Then .Parameters("wstocklabelid").value = -1
               If IsEmpty(.Parameters("wstocklabelid").value) Then .Parameters("wstocklabelid").value = 0
               
               If .Parameters("wstocklabelid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     .Parameters("id").value
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Private Sub ConvertFormulaMdb(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'  22May14 XN   Moved BatchStockLevel to new folder 81731
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertFormulaMdb"

Dim udtError As udtErrorState
   
   
   On Error Resume Next

  'Split out to own separate option 22May14 81731
  'ConvertBatchStockLevelTable lngSessionID, _
  '                            strSiteNumber, _
  '                            strDataDrive, _
  '                            strDbConn
   
   ConvertFormulaTable lngSessionID, _
                       strSiteNumber, _
                       strDataDrive, _
                       strDbConn
   
   ConvertLayoutTable lngSessionID, _
                      strSiteNumber, _
                      strDataDrive, _
                      strDbConn
   
   On Error GoTo 0
   
End Sub
Private Sub ConvertMediateMdb(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertMediateMdb"

Dim udtError As udtErrorState
   
   
   On Error Resume Next

   ConvertMediateTable lngSessionID, _
                       strSiteNumber, _
                       strDataDrive, _
                       strDbConn
   
   ConvertMediateArchiveTable lngSessionID, _
                              strSiteNumber, _
                              strDataDrive, _
                              strDbConn
   
   On Error GoTo 0
   
End Sub

Private Sub ConvertMediateArchiveTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertMediateArchiveTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8MediateArchiveAdoCmdObject strDbConn, _
                                     lngSessionID, _
                                     lngLocationID_Site, _
                                     adoCmd
      

   Set daoEngine = New DAO.DBEngine
   
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM MediateArchive", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM MediateArchive", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: MediateArchive table", _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
                              
               For lngLoop = 0 To daoRs.fields.Count - 1
                .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
               Next
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wmediatearchiveid").value) Then .Parameters("wmediatearchiveid").value = -1
               If IsEmpty(.Parameters("wmediatearchiveid").value) Then .Parameters("wmediatearchiveid").value = 0
               
               If .Parameters("wmediatearchiveid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertMediateTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertMediateTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8MediateAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoCmd
      

   Set daoEngine = New DAO.DBEngine
   
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Mediate", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM Mediate", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: Mediate table", _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
                              
               For lngLoop = 0 To daoRs.fields.Count - 1
                .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
               Next
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wmediateid").value) Then .Parameters("wmediateid").value = -1
               If IsEmpty(.Parameters("wmediateid").value) Then .Parameters("wmediateid").value = 0
               
               If .Parameters("wmediateid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertFormulaTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Oct07 EAC  Written
'  13Jul10 EAC  F0090667 Correct conversion of the quantity fields.
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "formula.mdb"
Const SUB_NAME = "ConvertFormulaTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
Dim strQty As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8FormulaAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoCmd
      

   Set daoEngine = New DAO.DBEngine
   
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Formula", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM Formula", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " + FILE_NAME + " - Formula table", _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
                              
               For lngLoop = 0 To daoRs.fields.Count - 1
                  Select Case LCase$(daoRs.fields(lngLoop).name)
                     Case "method"
                        .Parameters(daoRs.fields(lngLoop).name).value = Left$(GetField(daoRs.fields(lngLoop)), 1024)
                     Case "layout"
                        .Parameters(daoRs.fields(lngLoop).name).value = Left$(GetField(daoRs.fields(lngLoop)), 5000)
                     Case Else
                        If (.Parameters(daoRs.fields(lngLoop).name).Type = adDouble) Then
                           strQty = CStr(GetField(daoRs.fields(lngLoop)))
                           .Parameters(daoRs.fields(lngLoop).name).value = CDbl(strQty)
                        Else
                           .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
                        End If
                  End Select
               Next
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wformulaid").value) Then .Parameters("wformulaid").value = -1
               If IsEmpty(.Parameters("wformulaid").value) Then .Parameters("wformulaid").value = 0
               
               If .Parameters("wformulaid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertLayoutTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "formula.mdb"
Const SUB_NAME = "ConvertLayoutTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8LayoutAdoCmdObject strDbConn, _
                             lngSessionID, _
                             lngLocationID_Site, _
                             adoCmd
      

   Set daoEngine = New DAO.DBEngine
   
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Layout", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM Layout", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " + FILE_NAME + " - Layout table", _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
                              
               For lngLoop = 0 To daoRs.fields.Count - 1
                  .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
               Next
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wlayoutid").value) Then .Parameters("wlayoutid").value = -1
               If IsEmpty(.Parameters("wlayoutid").value) Then .Parameters("wlayoutid").value = 0
               
               If .Parameters("wlayoutid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertBatchStockLevelTable(ByVal lngSessionID As Long, _
                                        ByVal strSiteNumber As String, _
                                        ByVal strDataDrive As String, _
                                        ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "formula.mdb"
Const SUB_NAME = "ConvertBatchStockLevelTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8BatchStockLevelAdoCmdObject strDbConn, _
                                      lngSessionID, _
                                      lngLocationID_Site, _
                                      adoCmd
      

   Set daoEngine = New DAO.DBEngine
   
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM BatchStockLevel", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM BatchStockLevel", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " + FILE_NAME + " - BatchStockLevel table", _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
         
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               For lngLoop = 0 To daoRs.fields.Count - 1
                  .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
               Next
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
         
               If IsNull(.Parameters("wbatchstocklevelid").value) Then .Parameters("wbatchstocklevelid").value = -1
               If IsEmpty(.Parameters("wbatchstocklevelid").value) Then .Parameters("wbatchstocklevelid").value = 0
               
               If .Parameters("wbatchstocklevelid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Public Sub ConvertOrderFiles(ByVal lngSessionID As Long, _
                             ByVal strSiteNumber As String, _
                             ByVal strDataDrive As String, _
                             ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const ORDER_FILE_NAME = "order.v8"
Const ORDER_SP_NAME = "pV8WOrderInsert"

Const RECON_FILE_NAME = "reconcil.v8"
Const RECON_SP_NAME = "pV8WReconciliationInsert"

Const REQUIS_FILE_NAME = "requis.v8"
Const REQUIS_SP_NAME = "pV8WRequisitionInsert"

Const SUB_NAME = "ConvertOrderFiles"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim lngLocationID_Site As Long
   

   On Error GoTo ErrorHandler


   intSiteNumber = Val(strSiteNumber)
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8OrdersAdoCmdObject strDbConn, _
                             lngSessionID, _
                             lngLocationID_Site, _
                             adoCmd
   
   ConvertOrderFile strDataDrive, _
                    strSiteNumber, _
                    strDbConn, _
                    ORDER_FILE_NAME, _
                    ORDER_SP_NAME, _
                    adoCmd
                    
   ConvertOrderFile strDataDrive, _
                    strSiteNumber, _
                    strDbConn, _
                    RECON_FILE_NAME, _
                    RECON_SP_NAME, _
                    adoCmd
                    
   ConvertOrderFile strDataDrive, _
                    strSiteNumber, _
                    strDbConn, _
                    REQUIS_FILE_NAME, _
                    REQUIS_SP_NAME, _
                    adoCmd
                    
Cleanup:

   On Error Resume Next
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub
Private Sub ConvertStoresDefaultsFiles(ByVal lngSessionID As Long, _
                                       ByVal strSiteNumber As String, _
                                       ByVal strDataDrive As String, _
                                       ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Oct05 EAC  Written
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertStoresDefaultsFiles"

Dim udtError As udtErrorState

Dim cmdConfig As ADODB.Command
   
   On Error GoTo ErrorHandler

   BuildV8ConfigAdoCmdObject strDbConn, _
                             lngSessionID, _
                             cmdConfig
   
   cmdConfig.Parameters.item("locationid_site").value = FindSiteLocationID(lngSessionID, _
                                                                           strDbConn, _
                                                                           Val(strSiteNumber))
   
   ConvertOrderDatFile lngSessionID, _
                       strSiteNumber, _
                       strDataDrive, _
                       cmdConfig
                          
   ConvertStorevatDefFile lngSessionID, _
                          strSiteNumber, _
                          strDataDrive, _
                          cmdConfig
   
Cleanup:

   On Error Resume Next
   
   If Not cmdConfig Is Nothing Then
      cmdConfig.ActiveConnection.Close
      Set cmdConfig = Nothing
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertWardStockFile(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'  10Oct05 EAC  Moved conversion code to ConvertWardStockLayout
'               Added call to ConvertExtraSupplierDetails
'  12Nov14 XN   The supplier is now converted into WSuppluer_Old, WWardStockList_Old
'               table and is then converted into WWardProductList tables 103883
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertWardStockFile"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection
   
   On Error GoTo ErrorHandler

   ConvertWardStockLayout lngSessionID, _
                          strSiteNumber, _
                          strDataDrive, _
                          strDbConn
                          
   ConvertExtraSupplierData lngSessionID, _
                            strSiteNumber, _
                            strDataDrive, _
                            strDbConn
                               
   ' Convert data from WSupplier_Old to WWardProductList tables 12Nov14 XN 103883
   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   adoConn.Execute "Exec pWSupplierConvert 'WSupplier_Old', 'WExtraSupplierData_Old', 'WWardStockList_Old'"
   
   ' Convert data from WWardStockList_Old to WWardProductListLine 12Nov14 XN
   adoConn.Execute "Exec pWWardStockListConvert 'WWardStockList_Old', 'WSupplier_Old'"
   
Cleanup:

   
   On Error GoTo 0
   If Not (adoConn Is Nothing) Then adoConn.Close
   Set adoConn = Nothing
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub
Public Function AdoGetField(i_fld As ADODB.Field, Optional i_blnOriginalValue As Boolean) As Variant
' 2Apr96 CKJ Written
'            Avoids 'Invalid use of Null' problems by assigning
'            zero, "" or date'0' as appropriate.
'14Oct96 CKJ Null date now returns 0# not 31-12-1899
'01Sep00 CFY New parameter added so that you can now ask for the original value of a field
'25Oct00 JP  added type adDBTimeStamp 135, Indicates a date/time stamp (yyyymmddhhmmss plus a fraction in billionths)
'14Mar01 AE  Added ..Or IsEmpty.  ADO Fields in a new record can be empty, not null, prior to being set.
'
' 1 Boolean
' 2 Byte
' 3 Integer
' 4 Long
' 5 currency
' 6 single
' 7 double
' 8 date
' 9 ?  <not defined>
'10 text
'11 longbinary
'12 memo

Dim varValue As Variant

   If i_blnOriginalValue Then
         varValue = i_fld.OriginalValue
      Else
         varValue = i_fld.value
      End If
   
   If IsNull(varValue) Or IsEmpty(varValue) Then
         Select Case i_fld.Type
            Case 2 To 6, 14 To 21:     AdoGetField = 0
            Case 7, 135:               AdoGetField = 0#  'Format$(0, "dd-mm-yyyy")
            Case 200 To 203:           AdoGetField = ""
         End Select
      Else
         AdoGetField = varValue
      End If

End Function


Private Sub ConvertRxLogFiles(ByVal lngSessionID As Long, _
                              ByVal strSiteNumber As String, _
                              ByVal strDataDrive As String, _
                              ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  09Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const FILE_NAME = "rx*"
Const SUB_NAME = "ConvertRxLogFiles"

Dim udtError As udtErrorState
Dim udtLbl As WLabel

Dim lngLoop As Long

Dim strRxLogDir As String
Dim strRxLogName As String
   
   On Error GoTo ErrorHandler

   strRxLogDir = BuildV8FilePath(strDataDrive, _
                                 ePatdata, _
                                 strSiteNumber, _
                                 vbNullString)
                                    
   With frmMain.flstRxLogs
   
      .Path = strRxLogDir
   
      If .ListCount > 0 Then
      
         For lngLoop = .ListCount - 1 To 0 Step -1
         
            strRxLogName = .List(lngLoop)
            
            ConvertRxLogFile lngSessionID, _
                             strSiteNumber, _
                             strDataDrive, _
                             strDbConn, _
                             strRxLogName
         
         Next
      
      End If
   End With
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertRxLogFile(ByVal lngSessionID As Long, _
                             ByVal strSiteNumber As String, _
                             ByVal strDataDrive As String, _
                             ByVal strDbConn As String, _
                             ByVal strRxLogFilename As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  09Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertRxLogFile"

Dim udtError As udtErrorState
Dim udtLbl As WLabel

Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strTemp As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             ePatdata, _
                             strSiteNumber, _
                             strRxLogFilename)
                                    
   lngMaxFilePosn = ReadFilePointer(strFile)
   
   If lngMaxFilePosn > 1 Then
   
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              intSiteNumber)
      
      BuildV8LabelAdoCmdObject strDbConn, _
                               lngSessionID, _
                               lngLocationID_Site, _
                               adoCmd
      
      frmProgress.ShowProgress strSiteNumber, _
                               "Processing: " + strRxLogFilename, _
                               lngMaxFilePosn
                               
      frmMain.StartProgressTimer
      
      On Error GoTo DataError
      
      For lngFilePosn = 2 To lngMaxFilePosn
              
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePosn
            frmMain.StartProgressTimer
         End If
         
         udtLbl = GetDiskLabel(strFile, _
                               lngFilePosn)
         
            
         If Len(Trim$(udtLbl.StopDate)) > 0 Then
            With adoCmd
               .Parameters("dircode").value = udtLbl.dircode
               .Parameters("route").value = udtLbl.route
               .Parameters("equalinterval").value = udtLbl.EqualInterval
               .Parameters("timeunits").value = udtLbl.TimeUnits
               .Parameters("repeatinterval").value = udtLbl.repeatinterval
               .Parameters("repeatunits").value = udtLbl.repeatunits
               .Parameters("abstime").value = udtLbl.Abstime
               .Parameters("days").value = udtLbl.days
               .Parameters("baseprescriptionid").value = udtLbl.BasePrescriptionID
               For lngLoop = 1 To 6
                  .Parameters("dose" & Format$(lngLoop)).value = udtLbl.dose(lngLoop)
                  .Parameters("time" & Format$(lngLoop)).value = udtLbl.times(lngLoop)
               Next
               .Parameters("flags").value = udtLbl.flags
               .Parameters("prescriptionid").value = udtLbl.prescriptionid
               .Parameters("reconvol").value = udtLbl.ReconVol
               .Parameters("container").value = udtLbl.Container
               .Parameters("reconabbr").value = udtLbl.ReconAbbr
               .Parameters("diluentabbr").value = udtLbl.DiluentAbbr
               .Parameters("finalvolume").value = udtLbl.finalvolume
               .Parameters("drdirection").value = udtLbl.drdirection
               .Parameters("containersize").value = udtLbl.containersize
               .Parameters("infusiontime").value = udtLbl.InfusionTime
               .Parameters("prn").value = udtLbl.PRN
               .Parameters("patid").value = udtLbl.patid
               .Parameters("siscode").value = udtLbl.SisCode
               .Parameters("text").value = udtLbl.Text
               .Parameters("startdate").value = V8minsToSqlDate(udtLbl.startdate)
               .Parameters("stopdate").value = V8minsToSqlDate(udtLbl.StopDate)
               .Parameters("isstype").value = udtLbl.IssType
               .Parameters("lastqty").value = udtLbl.lastqty
               
               strTemp = trimz(udtLbl.lastdate)
               
               If Len(strTemp) > 0 Then
                  .Parameters("lastdate").value = Left$(strTemp, 2) & "-" & Mid$(strTemp, 3, 2) & "-" & Right$(strTemp, 2)
               Else
                  .Parameters("lastdate").value = Null
               End If
               
               .Parameters("topupqty").value = udtLbl.topupqty
               .Parameters("dispid").value = udtLbl.dispid
               .Parameters("prescriberid").value = udtLbl.prescriberid
               .Parameters("pharmacistid").value = udtLbl.PharmacistID
               .Parameters("stoppedby").value = udtLbl.StoppedBy
               .Parameters("rxstatus").value = udtLbl.rxstatus
               .Parameters("needednexttime").value = udtLbl.needednexttime
               .Parameters("rxstartdate").value = V8minsToSqlDate(udtLbl.RxStartDate)
               .Parameters("nodissued").value = udtLbl.NodIssued
               .Parameters("batchnumber").value = udtLbl.batchnumber
               .Parameters("extraflags").value = udtLbl.extraFlags
               .Parameters("deletedate").value = V8minsToSqlDate(udtLbl.deletedate)
               .Parameters("rxnodissued").value = udtLbl.RxNodIssued
               .Parameters("filename").value = strRxLogFilename
               .Parameters("fileposition").value = lngFilePosn
               .Execute , , adExecuteNoRecords
            
DataResume:
      
                If IsNull(adoCmd.Parameters("wlabelhistoryid").value) Then adoCmd.Parameters("wlabelhistoryid").value = -1
                If IsEmpty(adoCmd.Parameters("wlabelhistoryid").value) Then adoCmd.Parameters("wlabelhistoryid").value = 0
                      
                If adoCmd.Parameters("wlabelhistoryid").value <= 0 Then
                   LogConversionError udtError, _
                                      strSiteNumber, _
                                      strDbConn, _
                                      strFile, _
                                      lngFilePosn
                                      
                End If
             End With
         Else
          With udtError
             .Number = vbObjectError + 12346
             .Description = "No stop date defined in the label"
             .source = SUB_NAME
             .HelpFile = ""
             .HelpContext = 0
          End With
          LogConversionError udtError, _
                             strSiteNumber, _
                             strDbConn, _
                             strFile, _
                             lngFilePosn
         End If
                                         
         DoEvents
      
      Next
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   If Not adoCmd Is Nothing Then
      adoCmd.ActiveConnection.Close
      Set adoCmd.ActiveConnection = Nothing
      Set adoCmd = Nothing
   End If
   
   CloseLabelFile
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertLabelFile(ByVal lngSessionID As Long, _
                             ByVal strSiteNumber As String, _
                             ByVal strDataDrive As String, _
                             ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const LABEL_FILE_NAME = "LABELTXT.V6"
Const PATIENT_FILE_NAME = "PATID.V5"
Const SUB_NAME = "ConvertLabelFile"

Dim udtDataErr As udtErrorState
Dim udtError As udtErrorState
Dim udtLbl As WLabel

Dim adoCmd As ADODB.Command

Dim intHdl As Integer
Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strLblFile As String
Dim strPatientFile As String
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strLblFile = BuildV8FilePath(strDataDrive, _
                                ePatdata, _
                                strSiteNumber, _
                                LABEL_FILE_NAME)
                             
   strPatientFile = BuildV8FilePath(strDataDrive, _
                                    ePatdata, _
                                    strSiteNumber, _
                                    PATIENT_FILE_NAME)
                                    
   lngMaxFilePosn = ReadFilePointer(strLblFile)
   
   If lngMaxFilePosn > 1 Then
   
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              intSiteNumber)
      
      BuildV8LabelAdoCmdObject strDbConn, _
                               lngSessionID, _
                               lngLocationID_Site, _
                               adoCmd
      
      OpenPmrFile strSiteNumber, _
                  strDataDrive
                  
      OpenPatientFile strPatientFile
                  
      If gDebug Then
         intHdl = FreeFile()
         Open App.Path & "\debug.log" For Output As intHdl
         
         Print #intHdl, "Processing Label file : " + strLblFile
         
         Print #intHdl, "Processing Patient file : " + strPatientFile
         
         Print #intHdl, "Connection string : " + adoCmd.ActiveConnection.ConnectionString
         
         Print #intHdl, "Processing " + Format$(lngMaxFilePosn) + " labels"
      End If
      
      frmProgress.ShowProgress strSiteNumber, _
                               "Processing: " + LABEL_FILE_NAME, _
                               lngMaxFilePosn
                               
      frmMain.StartProgressTimer
      
      On Error GoTo DataError
      
      For lngFilePosn = 2 To lngMaxFilePosn
              
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePosn
            frmMain.StartProgressTimer
         End If
         
         If gDebug Then
            Print #intHdl, "File Posn = " + Format$(lngFilePosn)
         End If
         
         udtLbl = GetDiskLabel(strLblFile, _
                               lngFilePosn)
         
         If Not LabelMismatch(strSiteNumber, _
                              strDbConn, _
                              strLblFile, _
                              lngFilePosn, _
                              strDataDrive, _
                              udtLbl.patid, _
                              lngFilePosn) Then
            
            If gDebug Then
               Print #intHdl, "Label Matched: StopDate = '" + Format$(udtLbl.StopDate) + "'"
            End If
            
            If Len(Trim$(udtLbl.StopDate)) > 0 Then
               With adoCmd
                  .Parameters("dircode").value = udtLbl.dircode
                  .Parameters("route").value = udtLbl.route
                  .Parameters("equalinterval").value = udtLbl.EqualInterval
                  .Parameters("timeunits").value = udtLbl.TimeUnits
                  .Parameters("repeatinterval").value = udtLbl.repeatinterval
                  .Parameters("repeatunits").value = udtLbl.repeatunits
                  .Parameters("abstime").value = udtLbl.Abstime
                  .Parameters("days").value = udtLbl.days
                  For lngLoop = 1 To 6
                     .Parameters("dose" & Format$(lngLoop)).value = udtLbl.dose(lngLoop)
                     .Parameters("time" & Format$(lngLoop)).value = udtLbl.times(lngLoop)
                  Next
                  .Parameters("prescriptionid").value = udtLbl.prescriptionid
                  .Parameters("reconvol").value = udtLbl.ReconVol
                  .Parameters("container").value = udtLbl.Container
                  .Parameters("reconabbr").value = udtLbl.ReconAbbr
                  .Parameters("diluentabbr").value = udtLbl.DiluentAbbr
                  .Parameters("finalvolume").value = udtLbl.finalvolume
                  .Parameters("drdirection").value = udtLbl.drdirection
                  .Parameters("containersize").value = udtLbl.containersize
                  .Parameters("infusiontime").value = udtLbl.InfusionTime
                  .Parameters("prn").value = udtLbl.PRN
                  .Parameters("patid").value = udtLbl.patid
                  .Parameters("siscode").value = udtLbl.SisCode
                  .Parameters("text").value = udtLbl.Text
                  .Parameters("startdate").value = V8minsToSqlDate(udtLbl.startdate)
                  .Parameters("stopdate").value = V8minsToSqlDate(udtLbl.StopDate)
                  .Parameters("isstype").value = udtLbl.IssType
                  .Parameters("lastqty").value = udtLbl.lastqty
                  .Parameters("lastdate").value = Left$(udtLbl.lastdate, 2) & "-" & Mid$(udtLbl.lastdate, 3, 2) & "-" & Right$(udtLbl.lastdate, 2)
                  .Parameters("topupqty").value = udtLbl.topupqty
                  .Parameters("dispid").value = udtLbl.dispid
                  .Parameters("prescriberid").value = udtLbl.prescriberid
                  .Parameters("pharmacistid").value = udtLbl.PharmacistID
                  .Parameters("stoppedby").value = udtLbl.StoppedBy
                  .Parameters("rxstatus").value = udtLbl.rxstatus
                  .Parameters("needednexttime").value = udtLbl.needednexttime
                  .Parameters("rxstartdate").value = V8minsToSqlDate(udtLbl.RxStartDate)
                  .Parameters("nodissued").value = udtLbl.NodIssued
                  .Parameters("batchnumber").value = udtLbl.batchnumber
                  .Parameters("deletedate").value = V8minsToSqlDate(udtLbl.deletedate)
                  .Parameters("rxnodissued").value = udtLbl.RxNodIssued
                  .Parameters("baseprescriptionid").value = udtLbl.BasePrescriptionID
                  .Parameters("extraflags").value = udtLbl.extraFlags
                  .Parameters("filename").value = LABEL_FILE_NAME
                  .Parameters("fileposition").value = lngFilePosn
                  
                  .Execute , , adExecuteNoRecords
               
DataResume:
       
                   If IsNull(adoCmd.Parameters("wlabelhistoryid").value) Then adoCmd.Parameters("wlabelhistoryid").value = -1
                   If IsEmpty(adoCmd.Parameters("wlabelhistoryid").value) Then adoCmd.Parameters("wlabelhistoryid").value = 0
                   
                   If (gDebug) Then
                     Print #intHdl, "WLabelHistoryID = '" + Format$(adoCmd.Parameters("wlabelhistoryid").value) + "'"
                   End If
                   
                   If adoCmd.Parameters("wlabelhistoryid").value <= 0 Then
                      LogConversionError udtDataErr, _
                                         strSiteNumber, _
                                         strDbConn, _
                                         strLblFile, _
                                         lngFilePosn
                   End If
                End With
             Else
                With udtError
                   .Number = vbObjectError + 12346
                   .Description = "No stop date defined in the label"
                   .source = SUB_NAME
                   .HelpFile = ""
                   .HelpContext = 0
                End With
                LogConversionError udtError, _
                                   strSiteNumber, _
                                   strDbConn, _
                                   strLblFile, _
                                   lngFilePosn
             End If
          Else
            If gDebug Then
               Print #intHdl, "Label Mismatched."
            End If
          End If
                                         
         DoEvents
      
      Next
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   If gDebug Then
      Close #intHdl
   End If
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
   
   ClosePmrFile
   CloseLabelFile
   ClosePatientFile
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtDataErr, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Private Sub ConvertPatientFile(ByVal lngSessionID As Long, _
                               ByVal strSiteNumber As String, _
                               ByVal strDataDrive As String, _
                               ByVal strDbConn As String, _
                               ByRef daoEngine As DAO.DBEngine)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'  18Mar09 EAC  F0048514: Add option to only convert patient with prescriptions
'
'----------------------------------------------------------------------------------

Const EPISODE_DATABASE_NAME = "Patepisd.mdb"
Const PATIENT_DATABASE_NAME = "Patid.mdb"
Const PATIENT_FILE_NAME = "Patid.v5"
Const PMR_FILE_NAME = "Pmr.v5"
Const RX_INDEX_FILE_NAME = "Rx.idx"
Const SUB_NAME = "ConvertPatientFile"

Dim udtError As udtErrorState
                               
Dim daoEpisodeDb As DAO.Database
Dim daoEpisodeRs As DAO.Recordset
Dim daoNotesRs As DAO.Recordset
Dim daoPatientDb As DAO.Database
Dim daoPatientRs As DAO.Recordset

Dim adoPatCmd As ADODB.Command
Dim adoEpCmd As ADODB.Command

Dim boolConvertOnlyPatientsWithPrescriptions As Boolean
Dim boolConvertThisPatient As Boolean

Dim udtPatient As patidtype

Dim intSiteNumber As Integer

Dim lngEntityID As Long
Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long
Dim lngNumOfEpisodes As Long

Dim strEpisodeDb As String
Dim strPatientDb As String
Dim strPatientFile As String
Dim strPmrFile As String
Dim strRxIdxFile As String
Dim strRecno As String
Dim strV8PatientXml As String

   
   
   On Error GoTo ErrorHandler

   '18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
   boolConvertOnlyPatientsWithPrescriptions = (frmMain.optPatientSelection(1).value = True)
   
   intSiteNumber = Val(strSiteNumber)
   
   strEpisodeDb = BuildV8FilePath(strDataDrive, _
                                  ePatdata, _
                                  strSiteNumber, _
                                  EPISODE_DATABASE_NAME)
                                  
   strPatientDb = BuildV8FilePath(strDataDrive, _
                                  ePatdata, _
                                  strSiteNumber, _
                                  PATIENT_DATABASE_NAME)
   
   strPatientFile = BuildV8FilePath(strDataDrive, _
                                    ePatdata, _
                                    strSiteNumber, _
                                    PATIENT_FILE_NAME)
   
   lngMaxFilePosn = ReadFilePointer(strPatientFile)
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8PatientAdoCmdObject strDbConn, _
                              lngSessionID, _
                              lngLocationID_Site, _
                              adoPatCmd, _
                              adoEpCmd
       
   Set daoEpisodeDb = daoEngine.OpenDatabase(strEpisodeDb)
   
   Set daoPatientDb = daoEngine.OpenDatabase(strPatientDb)
   
   OpenPatientFile strPatientFile
   
   '18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
   If (boolConvertOnlyPatientsWithPrescriptions) Then
      OpenPmrFile strSiteNumber, strDataDrive
      
      OpenRxIndexFile strSiteNumber, strDataDrive
   End If
   
   frmProgress.ShowProgress strSiteNumber, _
                            "Processing the Patient and episode records.", _
                            lngMaxFilePosn
                            
   
   frmMain.StartProgressTimer
   
   On Error GoTo DataHandler
   
   For lngFilePosn = 2 To lngMaxFilePosn
      
      If frmMain.UpdateProgress Then
         frmProgress.UpdateProgress (lngFilePosn)
         
         frmMain.StartProgressTimer
      End If
      
      'read the patient from the PATID.V5 file
      udtPatient = GetPatientRecord(lngFilePosn)
      
      strRecno = trimz(udtPatient.recno)
      
      '18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
      boolConvertThisPatient = True
      
      If (boolConvertOnlyPatientsWithPrescriptions) Then
         ' In theory this should never happen as patients with historical prescriptions should already have
         ' entries in the PMR
         boolConvertThisPatient = DoesPatientHavePrescriptions(udtPatient, strRecno)
      End If
      
      If (boolConvertThisPatient) Then
         'read the patient data from the PATID.MDB
         Set daoPatientRs = daoPatientDb.OpenRecordset("SELECT * FROM Patid WHERE PatRecNo  = '" & strRecno & "'", _
                                                       DAO.RecordsetTypeEnum.dbOpenSnapshot)
                                                       
         Set daoNotesRs = daoPatientDb.OpenRecordset("SELECT * FROM PatNotes WHERE PatRecNo  = '" & strRecno & "'", _
                                                     DAO.RecordsetTypeEnum.dbOpenSnapshot)
                                                       
         'save the patient details
         SavePatient adoPatCmd, _
                     udtPatient, _
                     daoPatientRs, _
                     daoNotesRs, _
                     lngFilePosn, _
                     strPatientFile, _
                     strSiteNumber, _
                     strRecno, _
                     lngEntityID
                     
         If lngEntityID > 0 Then
            'read the episode data for the patient
            Set daoEpisodeRs = daoEpisodeDb.OpenRecordset("SELECT * FROM Episodes WHERE PatRecNo  = '" & strRecno & "'", _
                                                          DAO.RecordsetTypeEnum.dbOpenSnapshot)
                                          
            If Not daoEpisodeRs Is Nothing Then
               ConvertEpisodes intSiteNumber, _
                               strDataDrive, _
                               strRecno, _
                               lngEntityID, _
                               daoEpisodeRs, _
                               adoEpCmd
            End If
         End If
      End If
      
DataCleanup:

      DoEvents
   
   Next
   
   
Cleanup:

   On Error Resume Next
   
   frmProgress.ProgressHide
   
   adoPatCmd.ActiveConnection.Close
   Set adoPatCmd.ActiveConnection = Nothing
   Set adoPatCmd = Nothing
   
   ClosePatientFile
   
   '18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
   If (boolConvertOnlyPatientsWithPrescriptions) Then
      ClosePmrFile
      
      CloseRxIndexFile
   End If
   
   daoEpisodeDb.Close
   Set daoEpisodeDb = Nothing
   
   daoEpisodeRs.Close
   Set daoEpisodeRs = Nothing
   
   daoNotesRs.Close
   Set daoNotesRs = Nothing
   
   daoPatientDb.Close
   Set daoPatientDb = Nothing
   
   daoPatientRs.Close
   Set daoPatientRs = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   LogConversionError udtError, _
                      strSiteNumber, _
                      strDbConn, _
                      strPatientFile, _
                      lngFilePosn

   Resume DataCleanup
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Public Function ConvertStoresDefaults(ByVal lngSessionID As Long, _
                                      ByRef astrSiteNumbers() As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertStoresDefaults"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertStoresDefaultsFiles lngSessionID, _
                                 astrSiteNumbers(lngLoop), _
                                 strDataDrive, _
                                 strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertConsultantSpecialtyLinks(ByVal lngSessionID As Long, _
                                          ByRef astrSiteNumbers() As String, _
                                          ByVal strDataDrive As String, _
                                          ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Dec05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertConsultantSpecialtyLinks"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertConsSpecFile lngSessionID, _
                          astrSiteNumbers(lngLoop), _
                          strDataDrive, _
                          strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertWardSpecialtyLinks(ByVal lngSessionID As Long, _
                                          ByRef astrSiteNumbers() As String, _
                                          ByVal strDataDrive As String, _
                                          ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertWardSpecialtyLinks"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertWardSpecFile lngSessionID, _
                          astrSiteNumbers(lngLoop), _
                          strDataDrive, _
                          strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertDirections(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertDirections"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertDirectionFile lngSessionID, _
                           astrSiteNumbers(lngLoop), _
                           strDataDrive, _
                           strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertSpecialties(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  28Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertSpecialties"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertSpecialty lngSessionID, _
                       astrSiteNumbers(lngLoop), _
                       strDataDrive, _
                       strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertStockLabels(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  26Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertStockLabels"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertStockLabelMdb lngSessionID, _
                           astrSiteNumbers(lngLoop), _
                           strDataDrive, _
                           strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertMediateDbs(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertMediateDbs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertMediateMdb lngSessionID, _
                        astrSiteNumbers(lngLoop), _
                        strDataDrive, _
                        strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertFormulaDbs(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertFormulaDbs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertFormulaMdb lngSessionID, _
                        astrSiteNumbers(lngLoop), _
                        strDataDrive, _
                        strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertBatchStockLevels(ByVal lngSessionID As Long, _
                                        ByRef astrSiteNumbers() As String, _
                                        ByVal strDataDrive As String, _
                                        ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22May14 XN  Written (81731 split WBatchStockLevel from WFormular conversion)
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertBatchStockLevels"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertBatchStockLevelTable lngSessionID, _
                                  astrSiteNumbers(lngLoop), _
                                  strDataDrive, _
                                  strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function ConvertGPs(ByVal lngSessionID As Long, _
                           ByRef astrSiteNumbers() As String, _
                           ByVal strDataDrive As String, _
                           ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertGPs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertGPFile lngSessionID, _
                    astrSiteNumbers(lngLoop), _
                    strDataDrive, _
                    strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertRxLogs(ByVal lngSessionID As Long, _
                              ByRef astrSiteNumbers() As String, _
                              ByVal strDataDrive As String, _
                              ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertRxLogs"

Dim udtError As udtErrorState
      
Dim bProcessRxLogsFiles As Boolean

Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertRxLogFiles lngSessionID, _
                        astrSiteNumbers(lngLoop), _
                        strDataDrive, _
                        strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertLabels(ByVal lngSessionID As Long, _
                              ByRef astrSiteNumbers() As String, _
                              ByVal strDataDrive As String, _
                              ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertLabels"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertLabelFile lngSessionID, _
                       astrSiteNumbers(lngLoop), _
                       strDataDrive, _
                       strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertConsultants(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertConsultants"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertConsultantFile lngSessionID, _
                            astrSiteNumbers(lngLoop), _
                            strDataDrive, _
                            strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function ConvertSuppliers(ByVal lngSessionID As Long, _
                                 ByRef astrSiteNumbers() As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String, _
                                 ByVal lngLocationID_Parent As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'  12Nov14 XN   The supplier is now converted into WSuppluer_Old table and is then
'               converted into WSupplier2, and WCustomer tables 103883
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertSuppliers"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   ' 12Nov14 XN 103883 Now converts the data into WSupplier_Old
   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertSupplierFile lngSessionID, _
                          astrSiteNumbers(lngLoop), _
                          strDataDrive, _
                          strDbConn, _
                          lngLocationID_Parent
   Next
   
   ' Convert data from WSupplier_Old to WSupplier2, and WCustomer, and WWardProductList tables 12Nov14 XN 103883
   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   adoConn.Execute "Exec pWSupplierConvert 'WSupplier_Old', 'WExtraSupplierData_Old', 'WWardStockList_Old'"
   
Cleanup:

   On Error GoTo 0
   If Not (adoConn Is Nothing) Then adoConn.Close
   Set adoConn = Nothing
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertSupplierProfiles(ByVal lngSessionID As Long, _
                                        ByRef astrSiteNumbers() As String, _
                                        ByVal strDataDrive As String, _
                                        ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertSupplierProfiles"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertSupplierProfileMdb lngSessionID, _
                                astrSiteNumbers(lngLoop), _
                                strDataDrive, _
                                strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertConfigurationFiles(ByVal lngSessionID As Long, _
                                          ByRef astrDispSiteNumbers() As String, _
                                          ByRef astrPatSiteNumbers() As String, _
                                          ByVal strDataDrive As String, _
                                          ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrDispSiteNumbers  :  An array of V8 Dispdata SiteNumbers to be processed
'     astrPatSiteNumbers   :  An array of V8 Patdata SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SEARCH_CRITERIA = "*.INI"
Const SUB_NAME = "ConvertConfigurationFiles"

Dim udtError As udtErrorState
                               
Dim ContextCmd As ADODB.Command
Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim lngLocationID_Site As Long
Dim lngLoop As Long


   On Error GoTo ErrorHandler
                      
   BuildV8ConfigAdoCmdObject strDbConn, _
                             lngSessionID, _
                             adoCmd
                         
                             
   For lngLoop = LBound(astrDispSiteNumbers) To UBound(astrDispSiteNumbers)
      
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                              strDbConn, _
                                              Val(astrDispSiteNumbers(lngLoop)))
                                                                      
      adoCmd.Parameters("locationid_site").value = lngLocationID_Site
                                                  
      ConvertAscrootConfigurationFiles lngSessionID, _
                                       strDataDrive, _
                                       strDbConn, _
                                       adoCmd
      
      FindConfigFiles lngSessionID, _
                      strDataDrive, _
                      astrDispSiteNumbers(lngLoop), _
                      strDbConn, _
                      eDispdata, _
                      SEARCH_CRITERIA, _
                      adoCmd
                      
      ConvertLookupFiles lngSessionID, _
                         strDataDrive, _
                         astrDispSiteNumbers(lngLoop), _
                         strDbConn, _
                         eDispdata, _
                         lngLocationID_Site
                         
      ConvertDispdataReadptrFiles lngSessionID, _
                                  strDbConn, _
                                  strDataDrive, _
                                  astrDispSiteNumbers(lngLoop)
   Next
   
   For lngLoop = LBound(astrPatSiteNumbers) To UBound(astrPatSiteNumbers)
      ConvertPatdataReadptrFiles lngSessionID, _
                                 strDbConn, _
                                 strDataDrive, _
                                 astrPatSiteNumbers(lngLoop)
   Next
   
Cleanup:

   On Error Resume Next
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ConvertStoresFiles(ByVal lngSessionID As Long, _
                                   ByRef astrSiteNumbers() As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertStoresFiles"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertOrderFiles lngSessionID, _
                        astrSiteNumbers(lngLoop), _
                        strDataDrive, _
                        strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertWardStockDbs(ByVal lngSessionID As Long, _
                                    ByRef astrSiteNumbers() As String, _
                                    ByVal strDataDrive As String, _
                                    ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  15Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertWardStockDbs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertWardStockFile lngSessionID, _
                           astrSiteNumbers(lngLoop), _
                           strDataDrive, _
                           strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertPatients(ByVal lngSessionID As Long, _
                                ByRef astrSiteNumbers() As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertPatients"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long

Dim daoEngine As DAO.DBEngine


   On Error GoTo ErrorHandler

   Set daoEngine = New DAO.DBEngine
   
   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertPatientFile lngSessionID, _
                         astrSiteNumbers(lngLoop), _
                         strDataDrive, _
                         strDbConn, _
                         daoEngine
   Next
   
   
Cleanup:

   On Error Resume Next
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Private Sub ConvertWardStockLayout(ByVal lngSessionID As Long, _
                                   ByVal strSiteNumber As String, _
                                   ByVal strDataDrive As String, _
                                   ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Oct05 EAC  Written
'
'----------------------------------------------------------------------------------
Const FILE_NAME = "wslist.mdb"
Const SUB_NAME = "ConvertWardStockLayout"

Dim udtError As udtErrorState

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngMaxFilePosn As Long

Dim strExtraInfo As String
Dim strFile As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8WSLayoutAdoCmdObject strDbConn, _
                               lngSessionID, _
                               lngLocationID_Site, _
                               adoCmd
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Layout", dbOpenSnapshot)
      
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM Layout", dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            
            daoRs.MoveFirst
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            Do While Not daoRs.EOF
            
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               .Parameters("screenposn").value = GetField(daoRs.fields("screenposn"))
               .Parameters("nsvcode").value = GetField(daoRs.fields("nsvcode"))
               .Parameters("titletext").value = GetField(daoRs.fields("titletext"))
               .Parameters("printlabel").value = GetField(daoRs.fields("printlabel"))
               .Parameters("sitename").value = GetField(daoRs.fields("sitename"))
               .Parameters("topuplvl").value = GetField(daoRs.fields("topuplvl"))
               .Parameters("lastissue").value = GetField(daoRs.fields("lastissue"))
               .Parameters("packsize").value = GetField(daoRs.fields("packsize"))
               .Parameters("lastissuedate").value = GetField(daoRs.fields("lastissuedate"))
               .Parameters("localcode").value = GetField(daoRs.fields("localcode"))
               .Parameters("barcode").value = GetField(daoRs.fields("barcode"))
               .Parameters("dailyissue").value = GetField(daoRs.fields("dailyissue"))
               
               .Execute , , adExecuteNoRecords
               
DataResume:
      
               If IsNull(.Parameters("wwardstocklistid").value) Then .Parameters("wwardstocklistid").value = -1
               If IsEmpty(.Parameters("wwardstocklistid").value) Then .Parameters("wwardstocklistid").value = 0
               
               If .Parameters("wwardstocklistid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   Set daoRs = Nothing
   daoDb.Close
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Function FindSiteLocationID(ByVal lngSessionID As Long, _
                                    ByVal strDbConn As String, _
                                    ByVal intSiteNumber As Integer) As Long
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "FindSiteLocationID"

Dim udtError As udtErrorState
                                    
Dim adoConn As ADODB.Connection
Dim adoCmd As ADODB.Command


   On Error GoTo ErrorHandler

   FindSiteLocationID = -1
   
   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8ConvSiteInsert"
      .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("SiteNumber", adInteger, adParamInput, 4, intSiteNumber)
      .Parameters.Append .CreateParameter("LocationID_Site", adInteger, adParamOutput, 4)
      .Execute , , adExecuteNoRecords
      
      FindSiteLocationID = .Parameters("LocationID_Site").value
   End With
   
   

Cleanup:

   On Error Resume Next
   adoConn.Close
   Set adoConn = Nothing
   Set adoCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function InstallMetadata(ByVal lngSessionID As Long, _
                                ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Oct05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "InstallMetadata"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command


   On Error GoTo ErrorHandler

   BuildMetadataAdoCmdObject strDbConn, _
                             lngSessionID, _
                             adoCmd
                             
   adoCmd.Execute , , adExecuteNoRecords

Cleanup:

   On Error Resume Next
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Sub LogConversionError(ByRef Error As udtErrorState, _
                              ByVal SiteNumber As String, _
                              ByVal DBConn As String, _
                              ByVal File As String, _
                              ByRef FilePosn As Variant)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  06Apr05 EAC  Written
'  07Nov11 CKJ  Parse out password from DBConn, between pwd= and next double quote
'----------------------------------------------------------------------------------

Const SUB_NAME = "LogConversionError"

Dim strErr As String
Dim intPosn As Integer
Dim strPart As String
Dim strDB As String

   On Error Resume Next

   intPosn = InStr(1, DBConn, "pwd=", 1)
   If intPosn Then
      strDB = Left$(DBConn, intPosn + 3) + "****"
      strPart = Mid$(DBConn, intPosn + 4)
      intPosn = InStr(strPart, Chr$(34))
      If intPosn Then
         strDB = strDB & Mid$(strPart, intPosn)
      End If
   Else
      strDB = DBConn
   End If

   'changed DBConn to strDB
   strErr = "<ConversionError Occurred=""" & Date2TDate(CDate(Now)) & """>" & vbCrLf & _
            "<SiteNumber><![CDATA[" & SiteNumber & "</SiteNumber>" & vbCrLf & _
            "<ConnectionString><![CDATA[" & strDB & "]]></ConnectionString>" & vbCrLf & _
            "<V8File><![CDATA[" & File & "]]></V8File>" & vbCrLf & _
            "<FilePosition><![CDATA[" & FilePosn & "]]></FilePosn>" & vbCrLf & _
            "<ErrorStructure ErrorNumber=""" & Format$(Error.Number) & """>" & vbCrLf & _
            "<Source><![CDATA[" & Error.source & "]]></Source>" & vbCrLf & _
            "<Description><![CDATA[" & Error.Description & "]]></Description>" & _
            "</ErrorStructure>" & vbCrLf & _
            "</ConversionError>"

   LogString strErr
   
   Error.Number = 0
   
Cleanup:

   On Error GoTo 0

End Sub

Private Function MakeDate(ByVal strDDMMYYYY As String, _
                          ByVal strHHMM As String) As Variant
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  01Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "MakeDate"

Dim udtError As udtErrorState
                          

   On Error GoTo ErrorHandler

   If Len(strDDMMYYYY) = 0 Then
      MakeDate = Null
   Else
      If Len(strHHMM) = 0 Then strHHMM = "0000"
      MakeDate = CDate(Left$(strDDMMYYYY, 2) & "-" & _
                       Mid$(strDDMMYYYY, 3, 2) & "-" & _
                       Right$(strDDMMYYYY, 4) & " " & _
                       Left$(strHHMM, 2) & ":" & _
                       Right$(strHHMM, 2))
   End If
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   'CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   MakeDate = Null
   Resume Cleanup
   
End Function

Private Sub ProcessReadptrFile(ByVal strSiteNumber As String, _
                               ByVal strDbConn As String, _
                               ByVal strFileName As String, _
                               ByVal strCategory As String, _
                               ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  03Nov05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ProcessReadptrFile"

Dim udtError As udtErrorState
                               
Dim lngValue As Long


   On Error GoTo ErrorHandler

   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & strFileName, _
                            0
   
   lngValue = ReadFilePointer(strFileName)
   
   With adoCmd
      On Error GoTo DataHandler
      
      .Parameters.item("category").value = strCategory
      .Parameters.item("value").value = lngValue
      
      .Execute , , adExecuteNoRecords
      
DataResume:
      
      If IsNull(.Parameters("wfilepointerid").value) Then .Parameters("wfilepointerid").value = -1
      If IsEmpty(.Parameters("wfilepointerid").value) Then .Parameters("wfilepointerid").value = 0
      
      If .Parameters("wfilepointerid").value <= 0 Then
         LogConversionError udtError, _
                            strSiteNumber, _
                            strDbConn, _
                            strFileName, _
                            lngValue
      End If
      
   End With

Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub SavePatient(ByRef adoPatCmd As ADODB.Command, _
                        ByRef udtPid As patidtype, _
                        ByRef rsPid As DAO.Recordset, _
                        ByRef rsNotes As DAO.Recordset, _
                        ByVal lngFilePosn As Long, _
                        ByVal strFile As String, _
                        ByVal strSiteNumber As String, _
                        ByRef strRecno As String, _
                        ByRef lngEntityID As Long)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  01Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "SavePatient"

Dim udtError As udtErrorState

Dim lngSuccess As Long

Dim strHeight As String
Dim strWeight As String
Dim strFileHeight As String
Dim strFileWeight As String
Dim dblHeight As Double
Dim dblWeight As Double

Dim strDOB As String
Dim strDD As String
Dim strMM As String
Dim strNotes As String
Dim strYYYY As String

Dim varDOB As Variant

   On Error GoTo ErrorHandler
   
   lngEntityID = -1

   adoPatCmd.Parameters("entityid").value = -1
   adoPatCmd.Parameters("FilePosn").value = lngFilePosn
   strRecno = trimz(udtPid.recno)
   adoPatCmd.Parameters("Recno").value = strRecno
   adoPatCmd.Parameters("CaseNo").value = trimz(udtPid.caseno)
   adoPatCmd.Parameters("OldCaseno").value = trimz(udtPid.oldcaseno)
   adoPatCmd.Parameters("Surname").value = trimz(udtPid.surname)
   adoPatCmd.Parameters("Forename").value = trimz(udtPid.forename)
   strDOB = trimz(udtPid.dob)
   adoPatCmd.Parameters("DOBEstYear").value = 0
   adoPatCmd.Parameters("DOBEstMonth").value = 0
   adoPatCmd.Parameters("DOBEstDay").value = 0
   varDOB = Null
   If Len(strDOB) > 0 Then
      strDD = Left$(strDOB, 2)
      strMM = Mid$(strDOB, 3, 2)
      strYYYY = Right$(strDOB, 4)
      
      If strYYYY = "0000" Then
         adoPatCmd.Parameters("DOBEstYear").value = 1
         strYYYY = "1899"
      End If
      
      If strMM = "00" Then
         adoPatCmd.Parameters("DOBEstMonth").value = 1
         strMM = "01"
      End If
      
      If strDD = "00" Then
         adoPatCmd.Parameters("DOBEstDay").value = 1
         strDD = "01"
      End If
      If Val(strYYYY) > 1800 Then varDOB = CDate(strDD & "-" & strMM & "-" & strYYYY)
   End If
   adoPatCmd.Parameters("DOB").value = varDOB
   adoPatCmd.Parameters("Sex").value = trimz(udtPid.sex)
   adoPatCmd.Parameters("Ward").value = trimz(udtPid.ward)
   adoPatCmd.Parameters("Cons").value = trimz(udtPid.cons)
   
   strWeight = ""
   strHeight = ""
   
   strFileWeight = trimz(udtPid.weight)
   strFileHeight = trimz(udtPid.height)
   
   If (Len(strFileWeight) > 0) Then
      On Error GoTo WeightError
      dblWeight = CDbl(strFileWeight)
      strWeight = strFileWeight
WeightResume:
   End If
   
   If (Len(strFileHeight) > 0) Then
      On Error GoTo HeightError
      dblHeight = CDbl(strFileHeight)
      strHeight = strFileHeight
HeightResume:
   End If
   
   On Error GoTo ErrorHandler
   
   adoPatCmd.Parameters("Weight").value = strWeight
   adoPatCmd.Parameters("Height").value = strHeight
   adoPatCmd.Parameters("Status").value = trimz(udtPid.status)
   adoPatCmd.Parameters("Postcode").value = trimz(udtPid.postCode)
   adoPatCmd.Parameters("GP").value = trimz(udtPid.GP)
   
   If Not rsPid.EOF Then
      adoPatCmd.Parameters("HouseNumber").value = trimz(udtPid.HouseNumber)
      adoPatCmd.Parameters("NhNumber").value = GetField(rsPid.fields("nhnumber"))
      adoPatCmd.Parameters("NhNumberValid").value = GetField(rsPid.fields("nhnumvalid"))
      adoPatCmd.Parameters("Title").value = GetField(rsPid.fields("title"))
      adoPatCmd.Parameters("Address1").value = GetField(rsPid.fields("address1"))
      adoPatCmd.Parameters("Address2").value = GetField(rsPid.fields("address2"))
      adoPatCmd.Parameters("Address3").value = GetField(rsPid.fields("address3"))
      adoPatCmd.Parameters("Address4").value = GetField(rsPid.fields("address4"))
      adoPatCmd.Parameters("EthnicOrigin").value = GetField(rsPid.fields("ethnicorigin"))
      adoPatCmd.Parameters("AliasSurname").value = GetField(rsPid.fields("aliassurname"))
      adoPatCmd.Parameters("AliasForename").value = GetField(rsPid.fields("aliasforename"))
      adoPatCmd.Parameters("PPFlag").value = GetField(rsPid.fields("ppflag"))
      adoPatCmd.Parameters("EpisodeNum").value = GetField(rsPid.fields("episodenum"))
      adoPatCmd.Parameters("Specialty").value = GetField(rsPid.fields("Speciality"))
      adoPatCmd.Parameters("Allergy").value = GetField(rsPid.fields("allergy"))
      adoPatCmd.Parameters("Diagnosis").value = GetField(rsPid.fields("diagnosis"))
      adoPatCmd.Parameters("SurfaceArea").value = Val(GetField(rsPid.fields("surfacearea")))
   Else
      adoPatCmd.Parameters("HouseNumber").value = ""
      adoPatCmd.Parameters("NhNumber").value = ""
      adoPatCmd.Parameters("NhNumberValid").value = ""
      adoPatCmd.Parameters("Title").value = ""
      adoPatCmd.Parameters("Address1").value = ""
      adoPatCmd.Parameters("Address2").value = ""
      adoPatCmd.Parameters("Address3").value = ""
      adoPatCmd.Parameters("Address4").value = ""
      adoPatCmd.Parameters("EthnicOrigin").value = ""
      adoPatCmd.Parameters("AliasSurname").value = ""
      adoPatCmd.Parameters("AliasForename").value = ""
      adoPatCmd.Parameters("PPFlag").value = ""
      adoPatCmd.Parameters("EpisodeNum").value = ""
      adoPatCmd.Parameters("Specialty").value = ""
      adoPatCmd.Parameters("Allergy").value = ""
      adoPatCmd.Parameters("Diagnosis").value = ""
      adoPatCmd.Parameters("SurfaceArea").value = 0
   End If
   
   strNotes = ""
   If Not rsNotes Is Nothing Then
      If Not rsNotes.EOF Then strNotes = GetField(rsNotes.fields("notes"))

      '29Nov07 CKJ Trim extra space from notes - often has leading/trailing white space & cr/lf pairs
      strNotes = trimz(strNotes)       'remove beyond any null character
      Do While Len(strNotes) > 0       'remove leading white space
         Select Case Asc(strNotes)
            Case 10, 13, 32: strNotes = Mid$(strNotes, 2)
            Case Else:       Exit Do
            End Select
      Loop
      Do While Len(strNotes) > 0       'remove trailing white space
         Select Case Asc(Right$(strNotes, 1))
            Case 10, 13, 32: strNotes = Left$(strNotes, Len(strNotes) - 1)
            Case Else:       Exit Do
            End Select
      Loop
      '29Nov07 CKJ replace embedded 'crlfcrlfcrlf...' with 'crlfcrlf'
      ascReplace strNotes, vbCrLf & vbCrLf & vbCrLf, vbCrLf & vbCrLf, 0
      'Note that embedded chr$(160) remain in text
   End If
   
   'adoPatCmd.Parameters("Notes").value = Left$(strNotes, adoPatCmd.Parameters("Notes").Size)   '29Nov07 CKJ Now VarChar up to 8kb
   adoPatCmd.Parameters("Notes").value = Left$(strNotes, 8000)                                  '   "

   adoPatCmd.Execute lngSuccess, , adExecuteNoRecords
   

Cleanup:

   On Error Resume Next
   
   If IsNull(adoPatCmd.Parameters("entityid").value) Then adoPatCmd.Parameters("entityid").value = -1
   If IsEmpty(adoPatCmd.Parameters("entityid").value) Then adoPatCmd.Parameters("entityid").value = 0
   
   If adoPatCmd.Parameters("entityid").value <= 0 Then
      LogConversionError udtError, _
                         strSiteNumber, _
                         adoPatCmd.ActiveConnection.ConnectionString, _
                         strFile, _
                         lngFilePosn
   Else
      lngEntityID = adoPatCmd.Parameters("entityid").value
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
WeightError:
   'ignore the error and resume
   'if an error occurs then we won't use the weight value from the file as it is invalid.
   Resume WeightResume
   
HeightError:
   'ignore the error and resume
   'if an error occurs then we won't use the height value from the file as it is invalid.
   Resume HeightResume
   
End Sub
Private Function ReadFilePointer(ByVal strFilePath As String) As Long
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadFilePointer"

Dim udtError As udtErrorState

''Dim objReadptr As ASCReadPointerV1.ReapPointer

Dim lngReturn As Long


   On Error GoTo ErrorHandler

   ''lngReturn = -1

   ''Set objReadptr = New ASCReadPointerV1.ReadPointer
   
   ''objReadptr.GetPointer strFilePath, _
   ''                      lngReturn, _
   ''                      False
   
   GetPointer strFilePath, lngReturn, 0
   
Cleanup:

   On Error Resume Next
   ''Set objReadptr = Nothing
   
   ReadFilePointer = lngReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, "Filename = " + strFilePath
   Resume Cleanup
   
End Function

Private Sub ConvertConsultantFile(ByVal lngSessionID As Long, _
                                  ByVal strSiteNumber As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  17Mar05 EAC  Written
'  20Oct09 EAC  Handle description fields upto 128 characters in length.
'----------------------------------------------------------------------------------

Const DESCRIPTION_MAX_LENGTH = 128
Const FILE_NAME = "conscode.dat"
Const SUB_NAME = "ConvertConsultantFile"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim objFSO As Scripting.FileSystemObject
Dim objFile As Scripting.TextStream

Dim boolInUse As Boolean

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngMaxFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngSepPosn As Long

Dim strCode As String
Dim strExpn As String
Dim strLine As String
Dim strFile As String
   
   
   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             FILE_NAME)
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   Set objFSO = New Scripting.FileSystemObject
   
   If objFSO.fileexists(strFile) Then
   
      BuildV8ConsultantAdoCmdObject strDbConn, _
                                    lngSessionID, _
                                    lngLocationID_Site, _
                                    adoCmd
      
      Set objFile = objFSO.OpenTextFile(strFile, _
                                        ForReading)
      
      If Not objFile.AtEndOfStream Then
         
         strLine = objFile.ReadLine
         lngMaxFilePosn = Val(strLine)
         
         If lngMaxFilePosn > 0 Then
            
            frmProgress.ShowProgress strSiteNumber, _
                                     "Processing: " & FILE_NAME, _
                                     lngMaxFilePosn
                                     
            frmMain.StartProgressTimer
            
            On Error GoTo DataError
            
            For lngFilePosn = 0 To lngMaxFilePosn
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  
                  frmMain.StartProgressTimer
               End If
               
               If lngFilePosn = 0 Then
                  strCode = "XXXX"
                  strExpn = "Unknown consultant code"
                  boolInUse = True
               Else
                  If objFile.AtEndOfStream Then Exit For
                  
                  strLine = objFile.ReadLine
                  
                  strLine = Mid$(strLine, 2, Len(strLine) - 2)
                  lngSepPosn = InStr(1, strLine, Chr$(34) & "," & Chr$(34))
                  
                  strCode = Left$(strLine, lngSepPosn - 1)
                  strExpn = Left$(Mid$(strLine, lngSepPosn + 3), DESCRIPTION_MAX_LENGTH)
                  boolInUse = (InStr(1, strExpn, "#") = 0)
                  If Not boolInUse Then strExpn = Replace(strExpn, "#", "")
               End If
               
               adoCmd.Parameters("code").value = Trim$(strCode)
               adoCmd.Parameters("description").value = Trim$(strExpn)
               adoCmd.Parameters("inuse").value = boolInUse
               
               adoCmd.Execute , , adExecuteNoRecords
               
DataResume:
               
               If IsNull(adoCmd.Parameters("entityid").value) Then adoCmd.Parameters("entityid").value = -1
               If IsEmpty(adoCmd.Parameters("entityid").value) Then adoCmd.Parameters("entityid").value = 0
               
               If adoCmd.Parameters("entityid").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
            
            Next
         End If
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   objFile.Close
   Set objFile = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Sub ascReplace(item As String, was As String, isnow As String, ByVal length As Integer)
'Usage:  Replace part of one string with another, but only if it is greater than a given length
'        Note, this procedure _is_ case sensitive - it replaces only on exact match
'        Avoid iterative use: eg Replace chars$, "A", "AB", 0  will loop until crump.
'         - this is by design; it allows repetitive strings of chars to be cut to a minimum size
'           eg Replace chars$, "   ", "  ", 0   will reduce multiple spaces to just two.
'
'Example:
'        longname$ = "Mister Algernon Person"
'        Replace longname$, "Mister", "Mr.", 20   'will replace only if longname$ is > 20 chars
'        Replace longname$, "Algernon", "Al", 0   'will replace regardless of length

'05Oct96 CKJ Once replacing commenced, it carried on with all occurrences.
'            Now stops once length is satisfactory
'29May97 CKJ Splice new text into existing string if length before & after is unchanged
'            This is to reduce string handling & improve performance
'10Jul98 CKJ If length is negative then replace using case insensitive comparison
'            If the replace is not dependent on length then just use True for ignore case &
'            False for the normal case specific replace
'29Nov07 CKJ Copied from V8

Dim posn As Integer
Dim splice As Boolean
Dim ignorecase As Integer              '10Nov11 CKJ Corrected - must be Int not Boolean

   splice = (Len(was$) = Len(isnow))  ' if length is the same then splice is true
   ignorecase = -(length < 0)          ' set true/false
   length = Abs(length)
   If Len(item$) > length Then
         Do
            posn = InStr(1, item, was, ignorecase)    '10Jul98 CKJ added case option

            If posn Then
                 If splice Then
                       Mid$(item, posn) = isnow
                    Else
                       item = Left$(item, posn - 1) & isnow$ & Mid$(item, posn + Len(was))
                    End If
              End If
         Loop While posn And Len(item) > length
      End If

End Sub

Public Function ConvertTPNdefaults(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\TPNDEFLT.V5
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  01Nov11 CKJ  Written.
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNdefaults"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertTPNdefaultFile lngSessionID, _
                           astrSiteNumbers(lngLoop), _
                           strDataDrive, _
                           strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub ConvertTPNdefaultFile(ByVal lngSessionID As Long, _
                                       ByVal strSiteNumber As String, _
                                       ByVal strDataDrive As String, _
                                       ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\TPNDEFLT.V5
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  01Nov11 CKJ  Written.
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNdefaultFile"

Dim udtError As udtErrorState

Dim cmdConfig As ADODB.Command
   
   On Error GoTo ErrorHandler

   BuildV8ConfigAdoCmdObject strDbConn, _
                             lngSessionID, _
                             cmdConfig
   
   cmdConfig.Parameters.item("locationid_site").value = FindSiteLocationID(lngSessionID, _
                                                                           strDbConn, _
                                                                           Val(strSiteNumber))
   
   ConvertTPNdefltV5File lngSessionID, _
                          strSiteNumber, _
                          strDataDrive, _
                          cmdConfig
   
Cleanup:

   On Error Resume Next
   
   If Not cmdConfig Is Nothing Then
      cmdConfig.ActiveConnection.Close
      Set cmdConfig = Nothing
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Private Sub ConvertTPNdefltV5File(ByVal lngSessionID As Long, _
                                   ByVal strSiteNumber As String, _
                                   ByVal strDataDrive As String, _
                                   ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:     Convert TPNDEFLT.V5 to wConfiguration insert/update instructions
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
'TPNDEFLT.V5 is a binary file with two records
' Record 1 is Paediatric
' Record 2 is Adult
'Each record is of type tpndefaults
' Elements marked X are not for conversion
' Elements marked / update wConfiguration D|PN, PaedDefault or AdultDefault sections
'   Type tpndefaults                                                                         byte
'/      seplabels     As Integer            'T/F                     2 bytes 0000/ffff        1,2
'/      infusionrate  As Integer            'T/F                     2 bytes 0000/ffff        3,4
'X      dropspermin   As Integer            'T/F                     2 bytes 0000/ffff
'X      printreversefeed As Integer         'T/F                     2 bytes 0000/ffff
'/      baxapump      As Integer            'T/F                     2 bytes 0000/ffff        9,10
'X      plainprinter  As Integer            '1/2/3                   2 bytes 0100-0300
'X      labelprinter  As Integer            '1/2/3                   2 bytes 0100-0300
'/      issueenabled  As Integer            'T/F                     2 bytes 0000/ffff       15,16
'/      returnenabled As Integer            'T/F                     2 bytes 0000/ffff       17,18
'X      labels4inches As Integer            'T/F                     2 bytes 0000/ffff
'      ' 1 = Amino  2 = Fat  3 = Mixed
'/      overagevol(1 To 3) As Integer       'eg 50 mls         2x3   6 bytes 3200 (hex)      21,22    23,24    25,26
'/      Expiry(1 To 3) As String * 10       'DD/MM/YYYY       10x3  30 bytes "04/00/0000"    27-36    37-46    47-56
'/      numlabels(1 To 3) As Integer        'eg  2 labels      2x3   6 bytes 0100-0300       57,58    59,60    61,62
'/      infusehrs(1 To 3) As Integer        'eg 20 hrs         2x3   6 bytes 1400 (hex)      63,64    65,66    67,68
'X      dropsperml(1 To 3) As Integer       'eg 15 d/ml        2x3   6 bytes 0F00 (hex)      69,70    71,72    73,74
'   End Type                                                        74 bytes total

'   set @DefaultSection = 'PaedDefault' ... 'AdultDefault'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'SeparateAqueousAndLipidLabels', 'N'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'CalcDripRatemlPerHour', 'Y'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'BaxaCompounderInUse', 'N'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'IssueEnabled', 'N'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'ReturnEnabled', 'N'
'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'AqueousOverageVolumeInmL', '0'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'AqueousExpiryInDays', '4'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'AqueousNumberOfLabels', '2'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'AqueousInfusionDurationInHours', '24'
'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'LipidOverageVolumeInmL', '0'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'LipidExpiryInDays', '4'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'LipidNumberOfLabels', '1'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'LipidInfusionDurationInHours', '24'
'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'MixedOverageVolumeInmL', '0'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'MixedExpiryInDays', '4'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'MixedNumberOfLabels', '2'
'   exec [pWConfigurationWrite] 0, @siteid, 'D|PN',  @DefaultSection, 'MixedInfusionDurationInHours', '24'
'
' Modification History:
'  01Nov11 CKJ  Written
'
'----------------------------------------------------------------------------------
Const Category = "D|PN"
Const KEYNAMES = "SeparateAqueousAndLipidLabels|CalcDripRatemlPerHour|BaxaCompounderInUse|IssueEnabled|ReturnEnabled|" & _
                 "AqueousOverageVolumeInmL|LipidOverageVolumeInmL|MixedOverageVolumeInmL|" & _
                 "AqueousExpiryInDays|LipidExpiryInDays|MixedExpiryInDays|" & _
                 "AqueousNumberOfLabels|LipidNumberOfLabels|MixedNumberOfLabels|" & _
                 "AqueousInfusionDurationInHours|LipidInfusionDurationInHours|MixedInfusionDurationInHours"
Const KEYBYTES = "1,3,9,15,17," & _
                 "21,23,25," & _
                 "27,37,47," & _
                 "57,59,61," & _
                 "63,65,67"
Const TPNDEFLTV5_FILENAME = "TPNDEFLT.V5"
Const SUB_NAME = "ConvertTPNdefltV5File"

Dim udtError As udtErrorState
                                
Dim intCount As Integer
Dim intHdl As Integer

Dim astrKeyNames() As String
Dim astrKeyBytes() As String
Dim strFile As String
Dim strLine As String
Dim strSection As String
Dim abytData(1 To 74) As Byte
Dim intItem As Integer
Dim intValue As Integer
Dim intByte As Integer

   On Error GoTo ErrorHandler

   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, TPNDEFLTV5_FILENAME)

   astrKeyNames = Split(KEYNAMES, "|")
   astrKeyBytes = Split(KEYBYTES, ",")
   
   intHdl = FreeFile()
   Open strFile For Binary Lock Read Write As intHdl Len = 74
   
   frmProgress.ShowProgress strSiteNumber, _
                            "Processing: " & TPNDEFLTV5_FILENAME, _
                            0
                            
   On Error GoTo DataError
   
   strSection = "PaedDefault" '1st pass
   For intCount = 1 To 2
      Get #intHdl, , abytData()
      
      For intItem = 1 To 17
         intByte = Val(astrKeyBytes(intItem - 1))                                               'first byte of specified data element
         Select Case intItem
            Case 1 To 5                                                                         'Boolean
               strLine = "Y"
               If abytData(intByte) = 0 Then strLine = "N"                                      '0xFF/0x00 => Y/N
            Case 6 To 8, 12 To 14, 15 To 17                                                     'Integer
               strLine = Format$(abytData(intByte) + 256 * abytData(intByte + 1))               'LH' => int[L + 256 * H]
            Case 9 To 11                                                                        'Expiry-style date offset
               strLine = Format$(Val(Chr$(abytData(intByte)) & Chr$(abytData(intByte + 1))))    '04/00/0000' => '04' => "4"
            End Select
                           
         With adoCmd
            .Parameters("category").value = Category
            .Parameters("section").value = strSection
            .Parameters("key").value = astrKeyNames(intItem - 1)                                '0 to 16
            .Parameters("value").value = CreateConfigValue(strLine)

            .Execute , , adExecuteNoRecords
         End With
         
DataResume:
         If IsNull(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = -1
         If IsEmpty(adoCmd.Parameters("wconfigurationid").value) Then adoCmd.Parameters("wconfigurationid").value = 0

         If adoCmd.Parameters("wconfigurationid").value <= 0 Then
            LogConversionError udtError, _
                               strSiteNumber, _
                               adoCmd.ActiveConnection.ConnectionString, _
                               strFile, _
                               intCount
         End If

         DoEvents
      Next
      strSection = "AdultDefault"  '2nd pass
   Next
   
Cleanup:
   On Error Resume Next
   frmProgress.ProgressHide
   
   Close #intHdl
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub


Public Function ConvertTPNproductDBs(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String, _
                                  ByVal PNCode As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\TPNprds.mdb
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Nov11 CKJ  Written.
'  15Jul13 XN   35617 Add support of converting single PN Product
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNproductDBs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertTPNproductDB lngSessionID, _
                          astrSiteNumbers(lngLoop), _
                          strDataDrive, _
                          strDbConn, _
                          PNCode          ' 15Jul13 XN 35617 Add support of converting single PN Proudct
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub ConvertTPNproductDB(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String, _
                                 ByVal PNCode As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Nov11 CKJ  Written
'  15Jul13 XN   35617 Add support of converting single PN Product
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNproductDB"

Dim udtError As udtErrorState
   
'   On Error Resume Next

   ConvertPNproductTable lngSessionID, _
                         strSiteNumber, _
                         strDataDrive, _
                         strDbConn, _
                         PNCode                 ' 15Jul13 XN 35617 Add support of converting single PN Proudct
'!!**
   ConvertPNProductVersionTable lngSessionID, _
                                strSiteNumber, _
                                strDataDrive, _
                                strDbConn
   
'   On Error GoTo 0
   
End Sub


Private Sub ConvertPNproductTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String, _
                                ByVal PNCode As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Nov11 CKJ  Written
'  15Jul13 XN   35617 Add support of converting single PN Product
'  24Feb15 XN   95647 ConvertPNproductTable Prevent protien falling through to Case Else
'----------------------------------------------------------------------------------

Const FILE_NAME = "TPNprds.mdb"
Const SUB_NAME = "ConvertPNproductTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strQty As String
Dim V8Name As String
Dim strPNCodeWhereClause As String
      
   On Error GoTo ErrorHandler
   
   ' 15Jul13 XN 35617 Build where clause for converting single PN Product (otherwise blank)
   If PNCode <> "" Then strPNCodeWhereClause = " AND linkcode Like '" + PNCode + "' "

   intSiteNumber = Val(strSiteNumber)
   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, FILE_NAME)
   lngLocationID_Site = FindSiteLocationID(lngSessionID, strDbConn, intSiteNumber)
   BuildV8TPNproductAdoCmdObject strDbConn, lngSessionID, lngLocationID_Site, adoCmd
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   ' Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM PrdDat WHERE (val(prdtype) MOD 2)=1", dbOpenSnapshot)
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM PrdDat WHERE (val(prdtype) MOD 2)=1" + strPNCodeWhereClause, dbOpenSnapshot)  ' 15Jul13 XN 35617 Add support of converting single PN Product
   
   lngMaxFilePosn = daoRs.fields(0).value

   ' 15Jul13 XN 35617 Error if converting single Product that does not exits
   If PNCode <> "" And lngMaxFilePosn = 0 Then RaiseError erInvalidPNCode, PNCode
   
   'PrdType sum of PN=1 Enteral=2 Infusion=4, so to retain just PN products, mask using '.....xx1'
   '   Set daoRs = daoDb.OpenRecordset("SELECT * FROM PrdDat WHERE (val(prdtype) MOD 2)=1 ORDER BY SortCode ASC", dbOpenSnapshot)
   Set daoRs = daoDb.OpenRecordset("SELECT * FROM PrdDat WHERE (val(prdtype) MOD 2)=1 " + strPNCodeWhereClause + " ORDER BY SortCode ASC", dbOpenSnapshot)  ' 15Jul13 XN 35617 Add support of converting single PN Product
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            daoRs.MoveFirst
            frmProgress.ShowProgress strSiteNumber, "Processing: " + FILE_NAME + " - PrdDat table", lngMaxFilePosn
            frmMain.StartProgressTimer
            
            On Error GoTo DataError

            Do While Not daoRs.EOF
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               For lngLoop = 0 To daoRs.fields.Count - 1
                  V8Name = daoRs.fields(lngLoop).name

                  Select Case LCase$(V8Name)
                     Case "prdid"
                        'no action - new ID allocated in SQL Server
                     
                     Case "prdname"
                        .Parameters("Description").value = GetField(daoRs.fields(lngLoop))
                     
                     Case "linkcode"
                        .Parameters("PNcode").value = GetField(daoRs.fields(lngLoop))
                        .Parameters("StockLookup").value = GetField(daoRs.fields(lngLoop))   '27Jan12 Added
                     
                     Case "sortcode"
                        .Parameters("SortIndex").value = GetField(daoRs.fields(lngLoop))
                     
                     Case "solnab"
                        .Parameters("AqueousOrLipid").value = "A"                      'aqueous by default
                        If UCase$(GetField(daoRs.fields(lngLoop))) = "B" Then          'old 'solution B'
                           .Parameters("AqueousOrLipid").value = "L"                   'is lipid
                        End If
                     
                     Case "locked", "prdtype", "cost", "on_cost_%", "viscosity", "spike", "vacumatig"
                        'no action - fields are not being converted
                     
                     Case "containervol"
                        strQty = CStr(GetField(daoRs.fields(lngLoop)))
                        .Parameters("ContainerVol_mL").value = CDbl(strQty)

                    Case "protein"                                                 ' 95647 24Feb15 XN Prevent protien from falling through to Case Else
                        'no action - fields are not being converted
                        '   strQty = CStr(GetField(daoRs.Fields(lngLoop)))
                        '   .Parameters("Protein_grams").value = CDbl(strQty)   9Sep14 XN removed protien
                     
                     Case "phosphateisorganic"
                        If GetField(daoRs.fields(lngLoop)) = False Then                   'inorganic phosphate
                           strQty = CStr(GetField(daoRs.fields("Phosphate_mmol")))
                           .Parameters("PhosphateInorganic_mmol").value = CDbl(strQty)
                        Else                                                              'organic phosphate
                           .Parameters("PhosphateInorganic_mmol").value = 0
                        End If
                     
                     Case Else
                        If (.Parameters(daoRs.fields(lngLoop).name).Type = adDate) Then
                           .Parameters(daoRs.fields(lngLoop).name).value = daoRs.fields(lngLoop)      'allow Null date
                        ElseIf (.Parameters(daoRs.fields(lngLoop).name).Type = adDouble) Then
                           strQty = CStr(GetField(daoRs.fields(lngLoop)))
                           .Parameters(daoRs.fields(lngLoop).name).value = CDbl(strQty)
                        Else
                           .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
                        End If
                  End Select
               Next
               
               .Parameters("PNProductID").value = Empty
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
               If IsNull(.Parameters("PNProductID").value) Then .Parameters("PNProductID").value = -1
               If IsEmpty(.Parameters("PNProductID").value) Then .Parameters("PNProductID").value = 0
               
               If .Parameters("PNProductID").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Private Sub BuildV8TPNproductAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Nov11 CKJ  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8TPNproductAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8PNProductWrite"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("PNCode", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("StockLookup", adVarChar, adParamInput, 20, "") '27Jan12 CKJ added
      .Parameters.Append .CreateParameter("InUse", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("ForPaed", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("ForAdult", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 29, "")
      .Parameters.Append .CreateParameter("SortIndex", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PreMix", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("AqueousOrLipid", adChar, adParamInput, 1, "")
      .Parameters.Append .CreateParameter("MaxmlTotal", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("MaxmlPerKg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("SharePacks", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("BaxaMMIg", adVarChar, adParamInput, 13, "")
      .Parameters.Append .CreateParameter("mOsmperml", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("gH2Operml", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("SpGrav", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("LastModDate", adDate, adParamInput, , Null)
      .Parameters.Append .CreateParameter("LastModUser", adVarChar, adParamInput, 3, "")  '** consider widening &/or EntityID
      .Parameters.Append .CreateParameter("LastModTerm", adVarChar, adParamInput, 15, "") 'was 8 in V8
      .Parameters.Append .CreateParameter("Info", adVarChar, adParamInput, 255, "")       'varchar(max) but filled from text(255)
        
      .Parameters.Append .CreateParameter("ContainerVol_mL", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Calories_kcals", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Nitrogen_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Glucose_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Fat_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Sodium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Potassium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Calcium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Magnesium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Zinc_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Phosphate_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PhosphateInorganic_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Chloride_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Acetate_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Selenium_nanomol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Copper_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Iron_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Chromium_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Manganese_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Molybdenum_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Iodine_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Fluoride_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Vitamin_A_mcg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Thiamine_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Riboflavine_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Pyridoxine_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Cyanocobalamin_mcg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Pantothenate_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Folate_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Nicotinamide_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Biotin_mcg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Vitamin_C_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Vitamin_D_mcg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Vitamin_E_mg", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Vitamin_K_mcg", adDouble, adParamInput, , 0)
      '.Parameters.Append .CreateParameter("Protein_grams", adDouble, adParamInput, , 0)    9Sep14 XN removed protein
          
      .Parameters.Append .CreateParameter("PNProductID", adInteger, adParamOutput, 4)
   
   End With
   
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub

Public Function ConvertTPNruleDBs(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String, _
                                  ByVal strPNRuleNumber As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\StdRegs.mdb
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Nov11 CKJ  Written.
'  15Jul13 XN   35617 Add support of converting single PN Rule
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNruleDBs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertTPNruleDB lngSessionID, _
                       astrSiteNumbers(lngLoop), _
                       strDataDrive, _
                       strDbConn, _
                       strPNRuleNumber       ' 15Jul13 XN 35617 Add support of converting single PN Rule
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub ConvertTPNruleDB(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String, _
                                 ByVal strPNRuleNumber As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Nov11 CKJ Written
'  23Jan12 CKJ Enabled rule version conversion
'  15Jul13 XN   35617 Add support of converting single PN Rule
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNruleDB"

Dim udtError As udtErrorState
   
'   On Error Resume Next

   ConvertPNruleTable lngSessionID, _
                         strSiteNumber, _
                         strDataDrive, _
                         strDbConn, _
                         strPNRuleNumber        ' 15Jul13 XN 35617 Add support of converting single PN Rule
   
   ConvertPNRuleVersionTable lngSessionID, _
                             strSiteNumber, _
                             strDataDrive, _
                             strDbConn
   
'   On Error GoTo 0
   
End Sub


Private Sub ConvertPNruleTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String, _
                                ByVal strPNRuleNumber As String)
'----------------------------------------------------------------------------------
'
' Purpose:  Convert StdRegs Rules table
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Nov11 CKJ  Written
'  08Nov11 CKJ  Added Exclusion List from DSS
'  09Nov11 CKJ  Added LinkCodes to PNCodes, * to % and ? to _ replacement on RuleSQL
'  10Nov11 CKJ  Added single quotes round True and False
'  15Jul13 XN   35617 Add support of converting single PN Rule
'----------------------------------------------------------------------------------

Const FILE_NAME = "StdRegs.mdb"
Const SUB_NAME = "ConvertPNruleTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strQty As String
Dim V8Name As String
Dim V8SQL As String
Dim strSQL As String
Dim strPNRuleWhereClause As String

   On Error GoTo ErrorHandler
   
   ' 15Jul13 XN 35617 Build where clause for converting single PN Rule (otherwise blank)
   If strPNRuleNumber <> "" Then strPNRuleWhereClause = " AND RuleNumber=" + strPNRuleNumber + " "

   intSiteNumber = Val(strSiteNumber)
   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, FILE_NAME)
   lngLocationID_Site = FindSiteLocationID(lngSessionID, strDbConn, intSiteNumber)
   BuildV8TPNruleAdoCmdObject strDbConn, lngSessionID, lngLocationID_Site, adoCmd
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   'V8SQL = "SELECT COUNT(*) From Rules where RuleType IN(0,3,4)"
   V8SQL = "SELECT COUNT(*) From Rules where RuleType IN(0,3,4) " + strPNRuleWhereClause     ' 15Jul13 XN 35617 Add support of converting single PN Rule
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   ' 15Jul13 XN 35617 Error if converting single rule that does not exits
   If strPNRuleNumber <> "" And lngMaxFilePosn = 0 Then RaiseError erInvalidPNRule, strPNRuleNumber
   
   'exclude RuleType 1 (Rx proformas) ans 2 (clinical)
   V8SQL = "SELECT Description, RuleSQL, RuleNumber, RuleType, Critical, PerKilo, InUse, " & _
           "IngredientName as PNCode, IngredientAction as Ingredient, Explanation, LastModDate, LastModUser, LastModTerm, Info " & _
           "From Rules where RuleType IN(0,3,4) " + strPNRuleWhereClause + " order by RuleNumber ASC"    ' 15Jul13 XN 35617 Add support of converting single PN Rule
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            daoRs.MoveFirst
            frmProgress.ShowProgress strSiteNumber, "Processing: " + FILE_NAME + " - PNRules table", lngMaxFilePosn
            frmMain.StartProgressTimer
            
            On Error GoTo DataError

            Do While Not daoRs.EOF
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               Select Case GetField(daoRs!RuleNumber)    '08Nov11 CKJ Added Exclusion List from DSS
                  'Case 400, 405 To 415, 436 To 438, 445, 446, 464 To 477
                  'Case 516, 517, 520, 521, 526, 527, 544 To 549, 558 To 561, 578 To 585
                  'Case 598 To 627, 637 To 644, 651, 652, 661 To 672, 683, 684   ' 15Jul13 XN 35617 Moved to single line as no fall through
               
                  'No action for rules listed here
                  Case 400, 405 To 415, 436 To 438, 445, 446, 464 To 477, _
                       516, 517, 520, 521, 526, 527, 544 To 549, 558 To 561, 578 To 585, _
                       598 To 627, 637 To 644, 651, 652, 661 To 672, 683, 684
                     ' 15Jul13 XN Error if try  convert single row PN rule that is not supported
                     On Error GoTo ErrorHandler
                     If strPNRuleNumber <> "" Then RaiseError erPNRuleNoLongerSupported, strPNRuleNumber
                     
                  'Remaining rules are for conversion
                  Case Else
                     For lngLoop = 0 To daoRs.fields.Count - 1
                        V8Name = daoRs.fields(lngLoop).name
                        If LCase$(V8Name) = "rulesql" Then           '09Nov11 CKJ Added wildcard replacement
                           'Jet used * for wildcard, SQL uses %
                           'so       LinkCodes LIKE '%,THII500,%' OR LinkCodes LIKE '%,THII100,%'
                           'becomes  LinkCodes LIKE '%,THII500,%' OR LinkCodes LIKE '%,THII100,%'
                           strSQL = GetField(daoRs.fields(lngLoop))
                           ascReplace strSQL, "'*,", "'%,", True
                           ascReplace strSQL, ",*'", ",%'", True
                           
                           'Single wildcard was ? and is now _ but only used in last digits of a linkcode
                           'code  *,XYZI???,* becomes %,XYZI___,%
                           ascReplace strSQL, "????,%'", "____,%'", True
                           ascReplace strSQL, "???,%'", "___,%'", True
                           ascReplace strSQL, "??,%'", "__,%'", True
                           ascReplace strSQL, "?,%'", "_,%'", True
                           
                           'LinkCodes are now known as PNCodes when used within the PN tables
                           ascReplace strSQL, "LinkCodes", "PNCodes", True
                           
                           'True and False need single quotes
                           ascReplace strSQL, "True", "¬¬¬¬", True
                           ascReplace strSQL, "¬¬¬¬", "'True'", True
                           ascReplace strSQL, "False", "¬¬¬¬¬", True
                           ascReplace strSQL, "¬¬¬¬¬", "'False'", True
                           
                           .Parameters(daoRs.fields(lngLoop).name).value = strSQL
                        Else
                           If (.Parameters(daoRs.fields(lngLoop).name).Type = adDate) Then
                              .Parameters(daoRs.fields(lngLoop).name).value = daoRs.fields(lngLoop)      'allow Null date
                           ElseIf (.Parameters(daoRs.fields(lngLoop).name).Type = adDouble) Then
                              strQty = CStr(GetField(daoRs.fields(lngLoop)))
                              .Parameters(daoRs.fields(lngLoop).name).value = CDbl(strQty)
                           Else
                              .Parameters(daoRs.fields(lngLoop).name).value = GetField(daoRs.fields(lngLoop))
                           End If
                        End If
                     Next
                     
                     .Parameters("PNRuleID").value = Empty
                     
                     .Execute , , adExecuteNoRecords
                        
DataResume:
                     If IsNull(.Parameters("PNRuleID").value) Then .Parameters("PNRuleID").value = -1
                     If IsEmpty(.Parameters("PNRuleID").value) Then .Parameters("PNRuleID").value = 0
                     
                     If .Parameters("PNRuleID").value <= 0 Then
                        LogConversionError udtError, _
                                           strSiteNumber, _
                                           strDbConn, _
                                           strFile, _
                                           lngFilePosn
                     End If
                  End Select
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
Resume
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Private Sub BuildV8TPNruleAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Nov11 CKJ  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8TPNruleAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8PNRuleWrite"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("RuleNumber", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("RuleType", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("RuleSQL", adVarChar, adParamInput, 255, "")     'varchar(max) but filled from text(255)
      .Parameters.Append .CreateParameter("Critical", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PerKilo", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("InUse", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PNCode", adVarChar, adParamInput, 8, "")        'was IngredientName in V8, now used for ingredient to product only
      .Parameters.Append .CreateParameter("Ingredient", adVarChar, adParamInput, 5, "")    'was IngredientAction in V8, now used for ingredient to product only
      .Parameters.Append .CreateParameter("Explanation", adVarChar, adParamInput, 255, "") 'varchar(1024) but filled from text(255)
      .Parameters.Append .CreateParameter("LastModDate", adDate, adParamInput, , Null)
      .Parameters.Append .CreateParameter("LastModUser", adVarChar, adParamInput, 3, "")   '** consider widening &/or EntityID
      .Parameters.Append .CreateParameter("LastModTerm", adVarChar, adParamInput, 15, "")  'was 8 in V8
      .Parameters.Append .CreateParameter("Info", adVarChar, adParamInput, 255, "")        'varchar(max) but filled from text(255)
     
      .Parameters.Append .CreateParameter("PNRuleID", adInteger, adParamOutput, 4)
   
   End With
   
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub


Private Sub BuildPNLogAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Nov11 CKJ  Written
'  03Sep13 XN   72436 failed converting PN Log data as missing RequestID_Regimen parameter
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildPNLogAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pPNLogInsert"

      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("Occurred", adDate, adParamInput, , Now())
      .Parameters.Append .CreateParameter("UserInitials", adVarChar, adParamInput, 3, "")
      .Parameters.Append .CreateParameter("EntityID_User", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("TerminalName", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("SiteNumber", adInteger, adParamInput, , Null)
      .Parameters.Append .CreateParameter("LocationID_Site", adInteger, adParamInput, , lngLocationID_Site)
      .Parameters.Append .CreateParameter("EntityID_Patient", adInteger, adParamInput, , Null)
      .Parameters.Append .CreateParameter("EpisodeID", adInteger, adParamInput, , Null)
      .Parameters.Append .CreateParameter("PNProductID", adInteger, adParamInput, , Null)
      .Parameters.Append .CreateParameter("PNRuleID", adInteger, adParamInput, , Null)
      .Parameters.Append .CreateParameter("Description", adLongVarChar, adParamInput, -1, "")            'varchar(max)
      .Parameters.Append .CreateParameter("StackTrace text", adLongVarChar, adParamInput, -1, Null)      'varchar(max)
      .Parameters.Append .CreateParameter("RequestID_Regimen", adInteger, adParamInput, , Null)
          
      .Parameters.Append .CreateParameter("PNLogID", adInteger, adParamOutput, 4)
   End With
   
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub

Private Sub ConvertPNProductVersionTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'07Nov11 CKJ Written

   ConvertPNVersionTable lngSessionID, _
                         strSiteNumber, _
                         strDataDrive, _
                         strDbConn, _
                         "TPNprds.mdb"
                             
End Sub

Private Sub ConvertPNRuleVersionTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'07Nov11 CKJ Written

   ConvertPNVersionTable lngSessionID, _
                         strSiteNumber, _
                         strDataDrive, _
                         strDbConn, _
                         "StdRegs.mdb"

End Sub


Private Sub ConvertPNVersionTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String, _
                                ByVal strFileName As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Nov11 CKJ  Written
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertPNProductVersionTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strReport As String
Dim strEntry As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, strFileName)
   lngLocationID_Site = FindSiteLocationID(lngSessionID, strDbConn, intSiteNumber)
   BuildPNLogAdoCmdObject strDbConn, lngSessionID, lngLocationID_Site, adoCmd
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   Set daoRs = daoDb.OpenRecordset("SELECT COUNT(*) FROM Version ", dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   Set daoRs = daoDb.OpenRecordset("SELECT ModDate,Date,User,Version,Description FROM Version", dbOpenSnapshot)
   
   strReport = "V8 Data Conversion: File: " & strFile & vbCrLf
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            daoRs.MoveFirst
            frmProgress.ShowProgress strSiteNumber, "Processing: " + strFile + " - Version table", lngMaxFilePosn
            frmMain.StartProgressTimer
            
            On Error GoTo DataError

            Do While Not daoRs.EOF
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
                              
               If IsNull(daoRs.fields("ModDate")) Then
                  strEntry = Space$(19)
               Else
                  strEntry = Format$(daoRs.fields("ModDate"), "yyyy/mm/dd hh:nn:ss")
               End If
               
               strEntry = "Applied:" & strEntry & vbTab & _
                          "Created:" & GetField(daoRs.fields("Date")) & vbTab & _
                          "Author:" & GetField(daoRs.fields("User")) & vbTab & _
                          "Version:" & GetField(daoRs.fields("Version")) & vbTab & _
                          RTrim$(GetField(daoRs.fields("Description"))) & vbCrLf
                  
               strReport = strReport & strEntry
               DoEvents
               daoRs.MoveNext
            Loop
               
            .Parameters("UserInitials").value = "SYS"
            .Parameters("EntityID_User").value = 0
            .Parameters("TerminalName").value = "#V8DATACONVTOOL"
            .Parameters("SiteNumber").value = intSiteNumber
            .Parameters("Description").value = strReport       'varchar(max)
            .Parameters("PNLogID").value = Empty
            
            .Execute , , adExecuteNoRecords
                  
DataResume:
            If IsNull(.Parameters("PNLogID").value) Then .Parameters("PNLogID").value = -1
            If IsEmpty(.Parameters("PNLogID").value) Then .Parameters("PNLogID").value = 0
            
            If .Parameters("PNLogID").value <= 0 Then
               LogConversionError udtError, _
                                  strSiteNumber, _
                                  strDbConn, _
                                  strFile, _
                                  lngFilePosn
            End If
               
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Public Function ConvertTPNStdRegDBs(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\StdRegs.mdb
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Jan12 CKJ  Written.
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNStdRegDBs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertTPNStdRegDB lngSessionID, _
                       astrSiteNumbers(lngLoop), _
                       strDataDrive, _
                       strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub ConvertTPNStdRegDB(ByVal lngSessionID As Long, _
                                 ByVal strSiteNumber As String, _
                                 ByVal strDataDrive As String, _
                                 ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose: Convert one PN Standard Regimen database
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Jan12 CKJ  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNStdRegDB"

Dim udtError As udtErrorState
   
'   On Error Resume Next

   ConvertPNStdRegTable lngSessionID, _
                         strSiteNumber, _
                         strDataDrive, _
                         strDbConn
   
'Done as part of the PN Rule conversion, so not duplicated
'   ConvertPNRuleVersionTable lngSessionID, _
                             strSiteNumber, _
                             strDataDrive, _
                             strDbConn
   
'   On Error GoTo 0
   
End Sub


Private Sub ConvertPNStdRegTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDataDrive As String, _
                                ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:  Convert StdReg table
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Jan12 CKJ written
'----------------------------------------------------------------------------------

Const FILE_NAME = "StdRegs.mdb"
Const SUB_NAME = "ConvertPNStdRegTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command
Dim adoCmd2 As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strQty As String
Dim V8Name As String
Dim V8SQL As String
Dim strSQL As String
Dim strDesc As String
Dim sglTemp As String
Dim intValue As Integer
Dim strTemp As String

   On Error GoTo ErrorHandler
   
   intSiteNumber = Val(strSiteNumber)
   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, FILE_NAME)
   lngLocationID_Site = FindSiteLocationID(lngSessionID, strDbConn, intSiteNumber)
   BuildV8TPNStdRegAdoCmdObjects strDbConn, lngSessionID, lngLocationID_Site, adoCmd, adoCmd2
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   V8SQL = "SELECT COUNT(*) From StdReg where InUse = -1"
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   V8SQL = "SELECT * From StdReg where InUse = -1 order by StdRegID ASC"
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            daoRs.MoveFirst
            frmProgress.ShowProgress strSiteNumber, "Processing: " + FILE_NAME + " - StdReg table", lngMaxFilePosn
            frmMain.StartProgressTimer
            
            On Error GoTo DataError

            Do While Not daoRs.EOF
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If

               ReDim PNCode(1 To 25) As String * 8
               ReDim PrdVol(1 To 25) As Single
               
               For lngLoop = 0 To daoRs.fields.Count - 1
                  V8Name = daoRs.fields(lngLoop).name
                  Select Case LCase$(V8Name)
                     Case "regname"
                        .Parameters("RegimenName").value = GetField(daoRs.fields(lngLoop))
                     
                     Case "perkilo", "inuse"
                        .Parameters(V8Name).value = Abs(GetField(daoRs.fields(lngLoop)))     '-1 => 1 , 0 => 0
                     
                     Case "totgn"
                        strDesc = ""
                        sglTemp = GetField(daoRs.fields("TotgN"))
                        If sglTemp > 0 Then strDesc = "Nitrogen " & Format$(sglTemp)
                        
                        sglTemp = GetField(daoRs.fields("TotCal"))
                        If sglTemp > 0 Then strDesc = strDesc & "  Calories " & Format$(sglTemp)
                        
                        sglTemp = GetField(daoRs.fields("TotVol"))
                        If sglTemp > 0 Then strDesc = strDesc & "  Volume " & Format$(sglTemp)
                        
                        .Parameters("Description").value = Trim$(strDesc)

                     Case "lastmoddate"
                        strDesc = "Converted from V8"
                        If Not IsNull(daoRs.fields(lngLoop)) Then
                           strDesc = strDesc & " where last modification was on " & Format$(daoRs.fields(lngLoop), "dd/MM/yyyy hh:nn:ss")
                           strDesc = strDesc & " by " & GetField(daoRs.fields("lastmoduser"))
                           strDesc = strDesc & " terminal " & GetField(daoRs.fields("lastmodterm"))
                        End If
                        .Parameters("Information").value = strDesc
                        
                     Case "stdregid", "locked", "totcal", "totvol", "lastmoduser", "lastmodterm"
                        'no action
                        
                     Case Else  'handle code/volume pairs
                        If InStr(1, V8Name, "Lnk", 1) = 1 And Len(GetField(daoRs.fields(lngLoop))) > 0 Then    'Lnk## = "ABCI000"
                           intValue = Val(Mid$(V8Name, 4))  'Lnk1 to Lnk25
                           PNCode(intValue) = UCase$(Trim$(GetField(daoRs.fields(lngLoop))))
                           PrdVol(intValue) = GetField(daoRs.fields("Prd" & Format$(intValue)))
                        End If
                     End Select
               Next
               
               .Parameters("LastModDate").value = Now()
               .Parameters("LastModEntityID_User").value = 0
               .Parameters("LastModTerminal").value = 0
               .Parameters("PNStandardRegimenID").value = Empty
               
               .Execute , , adExecuteNoRecords
                  
DataResume:
               If IsNull(.Parameters("PNStandardRegimenID").value) Then .Parameters("PNStandardRegimenID").value = -1
               If IsEmpty(.Parameters("PNStandardRegimenID").value) Then .Parameters("PNStandardRegimenID").value = 0
               
               If .Parameters("PNStandardRegimenID").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               
               Else                  'write PNCode/Volume pairs
                  ConvertPNStdRegPNCodeVolumeTable lngSessionID, _
                                                   strSiteNumber, _
                                                   strDbConn, _
                                                   strFile, _
                                                   lngFilePosn, _
                                                   adoCmd2, _
                                                   .Parameters("PNStandardRegimenID").value, _
                                                   PNCode(), _
                                                   PrdVol()
               End If
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   adoCmd2.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd2.ActiveConnection = Nothing
   Set adoCmd = Nothing
   Set adoCmd2 = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
Resume
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

      
Private Sub ConvertPNStdRegPNCodeVolumeTable(ByVal lngSessionID As Long, _
                                ByVal strSiteNumber As String, _
                                ByVal strDbConn As String, _
                                ByVal strFile As String, _
                                ByVal lngFilePosn As Long, _
                                ByRef adoCmd As ADODB.Command, _
                                PNStandardRegimenID As Long, _
                                PNCode() As String * 8, _
                                PrdVol() As Single)
'----------------------------------------------------------------------------------
'
' Purpose:  Convert StdReg table - insert PNCode/Volume pairs
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'     adoCmd              :  existing, open & valid cmd object
'     PNStandardRegimenID :  existing ID to which new records will be linked
'     PNCode()            :  array of PN codes, blank is ignored
'     PrdVol()            :  array of corresponding volumes, <=0 is ignored
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Jan12 CKJ written
'----------------------------------------------------------------------------------

Const FILE_NAME = "StdRegs.mdb"
Const SUB_NAME = "ConvertPNStdRegPNcodeVolumeTable"

Dim udtError As udtErrorState
Dim intLoop As Integer

   On Error GoTo ErrorHandler
         
   With adoCmd
      frmProgress.ShowProgress strSiteNumber, "Processing: " + FILE_NAME + " - StdReg table (product volumes)", UBound(PNCode)
      frmMain.StartProgressTimer
      
      On Error GoTo DataError

      For intLoop = 1 To UBound(PNCode)
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress (intLoop)
            frmMain.StartProgressTimer
         End If
         
         If Len(PNCode(intLoop)) > 0 And PrdVol(intLoop) > 0 Then
            .Parameters("PNStandardRegimenID").value = PNStandardRegimenID
            .Parameters("PNCode").value = PNCode(intLoop)
            .Parameters("Volume").value = CDbl(Format$(PrdVol(intLoop)))
            .Parameters("PNStandardRegimenPNCodeVolumeID").value = Empty
                                  
            .Execute , , adExecuteNoRecords
            
DataResume:
            If IsNull(.Parameters("PNStandardRegimenPNCodeVolumeID").value) Then .Parameters("PNStandardRegimenPNCodeVolumeID").value = -1
            If IsEmpty(.Parameters("PNStandardRegimenPNCodeVolumeID").value) Then .Parameters("PNStandardRegimenPNCodeVolumeID").value = 0
            
            If .Parameters("PNStandardRegimenPNCodeVolumeID").value <= 0 Then
               LogConversionError udtError, _
                                  strSiteNumber, _
                                  strDbConn, _
                                  strFile, _
                                  lngFilePosn
            End If
            DoEvents
         End If
      Next
   End With
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
     
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
Resume
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub


Private Sub BuildV8TPNStdRegAdoCmdObjects(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command, _
                                       ByRef adoCmd2 As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Nov11 CKJ  Written
'               returns adoCmd  for pPNStandardRegimenInsert
'               returns adoCmd2 for pPNStandardRegimenPNCodeVolumeInsert
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8TPNStdRegAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      '.CommandText = "pV8PNStdRegWrite"
      .CommandText = "pPNStandardRegimenInsert"                'use standard SP
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("RegimenName", adVarChar, adParamInput, 30, "")
      .Parameters.Append .CreateParameter("PerKilo", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("InUse", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("Information", adVarChar, adParamInput, 255, "")        'varchar(max) but filled from shorter text
      .Parameters.Append .CreateParameter("LastModDate", adDate, adParamInput, , Null)
      .Parameters.Append .CreateParameter("LastModEntityID_User", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("LastModTerminal", adInteger, adParamInput, , 0)        'use LocationID
     
      .Parameters.Append .CreateParameter("PNStandardRegimenID", adInteger, adParamOutput, 4)
   End With
   
   Set adoCmd2 = New ADODB.Command
   
   With adoCmd2
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      '.CommandText = "pV8PNStdRegPNcodeVolumeWrite"
      .CommandText = "pPNStandardRegimenPNCodeVolumeInsert"    'use standard SP
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("PNStandardRegimenID", adInteger, adParamInput, 0)
      .Parameters.Append .CreateParameter("PNCode", adVarChar, adParamInput, 8, "")
      .Parameters.Append .CreateParameter("Volume", adDouble, adParamInput, , 0)
     
      .Parameters.Append .CreateParameter("PNStandardRegimenPNcodeVolumeID", adInteger, adParamOutput, 4)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub


Private Sub BuildV8PharmacyLogAdoCmdObject(ByVal strDbConn As String, _
                                       ByVal lngSessionID As Long, _
                                       ByVal lngLocationID_Site As Long, _
                                       ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose: Build parameters for pV8WPharmacyLogInsert (converting labutils)
'
' Inputs:
'     strDbConn :           Connection string
'     lngSessionID:         Session ID
'     lngLocationID_Site:   site ID
'     adoCmd:               Command
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  19Feb14 XN  Written 56701
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8PharmacyLogAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8WPharmacyLogInsert"                'use standard SP
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("SiteID", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("dateTime", adDate, adParamInput, 8, 0)
      .Parameters.Append .CreateParameter("entityID_User", adInteger, adParamInput, 4, 0)
      .Parameters.Append .CreateParameter("Terminal", adVarChar, adParamInput, 15, "")
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 8000, "")        'varchar(max) but filled from shorter text
      .Parameters.Append .CreateParameter("Detail", adVarChar, adParamInput, 8000, "")
      .Parameters.Append .CreateParameter("NSVCode", adVarChar, adParamInput, 8, "")
     
      .Parameters.Append .CreateParameter("WPharmacyLogID", adInteger, adParamOutput, 4)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub


Private Sub BuildV8RichTextDocumentAdoCmdObject(ByVal strDbConn As String, _
                                                ByVal lngSessionID As Long, _
                                                ByVal routineName As String, _
                                                ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose: Build parameters for pV8WPharmacyLogInsert (converting labutils)
'
' Inputs:
'     strDbConn :   Connection string
'     lngSessionID: Session ID
'     routineName:  Name of the routine stored in the Routine table used to populate the report
'     adoCmd:       Command
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  21May14 XN  Written 88857
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8RichTextDocumentAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8RichTextDocumentWrite"                'use standard SP
      .Parameters.Append .CreateParameter("CurrentSessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 8000, "")
      .Parameters.Append .CreateParameter("Detail", adVarChar, adParamInput, 8000, "")
      .Parameters.Append .CreateParameter("Routine", adVarChar, adParamInput, Len(routineName), routineName)
      .Parameters.Append .CreateParameter("RichTextDocumentID", adInteger, adParamOutput, 4)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub


Public Function ConvertTPNRxProformaDBs(ByVal lngSessionID As Long, _
                                  ByRef astrSiteNumbers() As String, _
                                  ByVal strDataDrive As String, _
                                  ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\StdRegs.mdb Rules table, Rule type 1 only
'           Prescription Pro-formas
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     astrSiteNumbers      :  An array of V8 SiteNumbers to be processed
'     strDataDrive         :  The drive letter where the V8 data resides
'     strDbConn            :  The database connection string for the V92 database
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  23Jan12 CKJ  Written.
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNRxProformaDBs"

Dim udtError As udtErrorState
                               
Dim lngLoop As Long


   On Error GoTo ErrorHandler

   For lngLoop = LBound(astrSiteNumbers) To UBound(astrSiteNumbers)
      ConvertTPNRxProformaDB lngSessionID, _
                              astrSiteNumbers(lngLoop), _
                              strDataDrive, _
                              strDbConn
   Next
   
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub ConvertTPNRxProformaDB(ByVal lngSessionID As Long, _
                                    ByVal strSiteNumber As String, _
                                    ByVal strDataDrive As String, _
                                    ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:  Converts dispdata.xxx\StdRegs.mdb Rules table, Rule type 1 only
'           Prescription Pro-formas
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  23Jan12 CKJ Written
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertTPNRxProformaDB"

Dim udtError As udtErrorState
   
'   On Error Resume Next

   ConvertTPNRxProformaTable lngSessionID, _
                             strSiteNumber, _
                             strDataDrive, _
                             strDbConn
   
'Done as part of PNRule conversion so not duplicated
'   ConvertPNRuleVersionTable lngSessionID, _
                             strSiteNumber, _
                             strDataDrive, _
                             strDbConn
   
'   On Error GoTo 0
   
End Sub

Private Sub ConvertTPNRxProformaTable(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strDbConn As String)
'----------------------------------------------------------------------------------
'
' Purpose:  Convert StdRegs Rules table where RuleType = 1
'           Prescription Pro-formas
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  23Jan12 CKJ  Written
'----------------------------------------------------------------------------------

Const FILE_NAME = "StdRegs.mdb"
Const SUB_NAME = "ConvertTPNRxProformaTable"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command
Dim adoCmd2 As ADODB.Command

Dim daoEngine As DAO.DBEngine
Dim daoDb As DAO.Database
Dim daoRs As DAO.Recordset

Dim intSiteNumber As Integer

Dim lngFilePosn As Long
Dim lngLocationID_Site As Long
Dim lngLoop As Long
Dim lngMaxFilePosn As Long

Dim strFile As String
Dim strQty As String
Dim V8Name As String
Dim V8SQL As String
Dim strSQL As String

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, FILE_NAME)
   lngLocationID_Site = FindSiteLocationID(lngSessionID, strDbConn, intSiteNumber)
   BuildV8TPNRxProformaAdoCmdObject strDbConn, lngSessionID, lngLocationID_Site, adoCmd, adoCmd2
      
   Set daoEngine = New DAO.DBEngine
   Set daoDb = daoEngine.OpenDatabase(strFile)
   
   V8SQL = "SELECT COUNT(*) From Rules where RuleType=1 and InUse=True"
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   lngMaxFilePosn = daoRs.fields(0).value
   
   'only include RuleType 1 (Rx proformas)
   V8SQL = "SELECT Description, RuleSQL, RuleNumber, RuleType, Critical, PerKilo, InUse, " & _
           "Explanation, LastModDate, LastModUser, LastModTerm, Info, " & _
           "Volume as Volume_mL, Nitrogen as Nitrogen_grams, Glucose as Glucose_grams, " & _
           "Fat as Fat_grams, Sodium as Sodium_mmol, Potassium as Potassium_mmol, " & _
           "Calcium as Calcium_mmol, Magnesium as Magnesium_mmol, " & _
           "Zinc as Zinc_micromol, Phosphate as Phosphate_mmol, " & _
           "Selenium as Selenium_nanomol, Copper as Copper_micromol, " & _
           "AquVitamins as AqueousVitamins_mL, FatVitamins as LipidVitamins_mL, Iron as Iron_micromol " & _
           "From Rules where RuleType=1 and InUse=True order by RuleNumber ASC"
   Set daoRs = daoDb.OpenRecordset(V8SQL, dbOpenSnapshot)
   
   'Calories, Chloride & Acetate were always 0 in V8, with no machinery to handle them
   'therefore not porting these across to web version.
   
   If Not daoRs Is Nothing Then
      
      If Not daoRs.EOF Then
         With adoCmd
            daoRs.MoveFirst
            frmProgress.ShowProgress strSiteNumber, "Processing: " + FILE_NAME + " - PNRules table", lngMaxFilePosn
            frmMain.StartProgressTimer
            
            On Error GoTo DataError

            Do While Not daoRs.EOF
               lngFilePosn = lngFilePosn + 1
               
               If frmMain.UpdateProgress Then
                  frmProgress.UpdateProgress lngFilePosn
                  frmMain.StartProgressTimer
               End If
               
               For lngLoop = 0 To daoRs.fields.Count - 1
                  V8Name = daoRs.fields(lngLoop).name
                  Select Case LCase$(V8Name)
                     Case "rulesql"            '09Nov11 CKJ Added wildcard replacement
                        'Jet used * for wildcard, SQL uses %  !!** no wildcards here
                        strSQL = GetField(daoRs.fields(lngLoop))
                        
                        'True and False need single quotes
                        ascReplace strSQL, "True", "¬¬¬¬", True
                        ascReplace strSQL, "¬¬¬¬", "'True'", True
                        ascReplace strSQL, "False", "¬¬¬¬¬", True
                        ascReplace strSQL, "¬¬¬¬¬", "'False'", True
                        
                        .Parameters(daoRs.fields(lngLoop).name).value = strSQL
                                             
                     Case Else
                        If (.Parameters(V8Name).Type = adDate) Then
                           .Parameters(V8Name).value = daoRs.fields(lngLoop)      'allow Null date
                        ElseIf (.Parameters(V8Name).Type = adDouble) Then
                           strQty = CStr(GetField(daoRs.fields(lngLoop)))
                           .Parameters(V8Name).value = CDbl(strQty)
                        Else
                           .Parameters(V8Name).value = GetField(daoRs.fields(lngLoop))
                        End If
                     End Select
               Next
               
               .Parameters("PNRuleID").value = Empty
               
               '-- delete existing row if any, from both tables
               adoCmd2.Parameters("RuleNumber").value = CLng(daoRs.fields("RuleNumber").value)
               adoCmd2.Execute , , adExecuteNoRecords
               
               '-- insert new row in both tables
               .Execute , , adExecuteNoRecords
                  
DataResume:
               If IsNull(.Parameters("PNRuleID").value) Then .Parameters("PNRuleID").value = -1
               If IsEmpty(.Parameters("PNRuleID").value) Then .Parameters("PNRuleID").value = 0
               
               If .Parameters("PNRuleID").value <= 0 Then
                  LogConversionError udtError, _
                                     strSiteNumber, _
                                     strDbConn, _
                                     strFile, _
                                     lngFilePosn
               End If
               
               DoEvents
               daoRs.MoveNext
            Loop
         End With
      End If
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd2.ActiveConnection.Close
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd2.ActiveConnection = Nothing
   Set adoCmd = Nothing
   Set adoCmd2 = Nothing
         
   daoRs.Close
   daoDb.Close
   
   Set daoRs = Nothing
   Set daoDb = Nothing
   Set daoEngine = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
Resume
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                               
End Sub

Public Function ConvertPharmacyLogs(ByVal lngSessionID As Long, _
                                    ByRef strSiteNumbers() As String, _
                                    ByVal strDataDrive As String, _
                                    ByVal strDBName As String, _
                                    ByVal strDbConn As String) As String
    Dim SiteNumber As Variant
    For Each SiteNumber In strSiteNumbers
        ConvertPharmacyLog lngSessionID, SiteNumber, strDataDrive, strDBName, strDbConn
    Next
End Function

Private Function ConvertPharmacyLog(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strDBName As String, _
                                      ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Convert WPharmacyLog (e.g. labutils)
'
' Inputs:
'     lngSessionID:  Standard sessionid
'     strSiteNumber: Site number
'     strDataDrive:  Drive for files
'     strDBName:     DB log WPharmacyLogType
'     strDbConn:     Connection string
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  149Feb14 XN  Written 56701
'  07Apr16  XN  Added Negative, and GainLoss logs
'  05Apr17  TH  Added PNEdit and Reconcil
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertPharmacyLog"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command
Dim adoCmd2 As ADODB.Command

Dim udtPharmacyLog As pharmacylogstruct

Dim intSiteNumber As Integer

Dim lngFilePos As Long
Dim lngFound As Long
Dim lngLocationID_Site As Long
Dim lngFileSize As Long
Dim strFile As String
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   'strFile = BuildV8FilePath(strDataDrive, eAscroot, strSiteNumber, strFilename)
   ' Get the file based on log type 123082 07Apr16 XN
   Select Case LCase(strDBName)
   Case "labutils"
        strFile = BuildV8FilePath(strDataDrive, eAscroot, strSiteNumber, "LabUtils.log")
   Case "reconcil"
        strFile = BuildV8FilePath(strDataDrive, eAscroot, strSiteNumber, "Reconcil.log") '05Apr17 TH Added
   Case "gainloss"
        strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, "GainLoss.log")
   Case "negative"
        strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, "Negative.log")
   Case "pnedit"
        strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, "PNEdit.log") '05Apr17 TH Added
   Case "editors"
        strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, "Editors.log") '06Apr17 TH Added
   Case "escissue"
        strFile = BuildV8FilePath(strDataDrive, eDispdata, strSiteNumber, "escissue.log") '13Apr17 TH Added
   End Select
                                    
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildV8PharmacyLogAdoCmdObject strDbConn, _
                                lngSessionID, _
                                lngLocationID_Site, _
                                adoCmd
                                
   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
                                
   Dim recordSets As ADODB.Recordset
   Set recordSets = adoConn.Execute("SELECT Person.EntityID, Initials FROM Person JOIN [user] ON Person.EntityID = [user].EntityID WHERE Initials<>''")
   
   lngFileSize = FileLen(strFile)
         
   If lngFileSize > 1 Then
   
      frmProgress.ShowProgress strSiteNumber, _
                               "Processing: " & strDBName, _
                               lngFileSize
                               
      frmMain.StartProgressTimer
      
      On Error GoTo DataError
      
      While lngFilePos < lngFileSize
      
         If frmMain.UpdateProgress Then
            frmProgress.UpdateProgress lngFilePos
            
            frmMain.StartProgressTimer
         End If
                 
         'udtPharmacyLog = GetPharmacyLog(strFile, strSiteNumber, lngFilePos, lngFound)
                 ' Read the log based on log type 123082 07Apr16 XN
         Select Case LCase(strDBName)
         Case "labutils"
             udtPharmacyLog = GetLabUtilsLog(strFile, strSiteNumber, lngFilePos, lngFound)
         Case "reconcil"
             udtPharmacyLog = GetReconcilLog(strFile, strSiteNumber, lngFilePos, lngFound) '05Apr17 TH Added
         Case "gainloss"
             udtPharmacyLog = GetGainLossLog(strFile, strSiteNumber, lngFilePos, lngFound)
         Case "negative"
             udtPharmacyLog = GetNegativeLog(strFile, strSiteNumber, lngFilePos, lngFound)
         Case "pnedit"
             udtPharmacyLog = GetPNEditLog(strFile, strSiteNumber, lngFilePos, lngFound) '05Apr17 TH Added
         Case "editors"
             udtPharmacyLog = GetEditorsLog(strFile, strSiteNumber, lngFilePos, lngFound) '05Apr17 TH Added
         Case "escissue"
             udtPharmacyLog = GetEscIssueLog(strFile, strSiteNumber, lngFilePos, lngFound) '05Apr17 TH Added
         End Select
      
         If lngFound > 0 Then
            With adoCmd.Parameters
               .item("SiteID").value = lngLocationID_Site
               .item("dateTime").value = CDate(udtPharmacyLog.DateTime.Yrs & "-" & udtPharmacyLog.DateTime.Mth & "-" & udtPharmacyLog.DateTime.Day & " " & udtPharmacyLog.DateTime.Hrs & ":" & udtPharmacyLog.DateTime.min & ":" & udtPharmacyLog.DateTimeSec)
               .item("entityID_User").value = FindUserID(udtPharmacyLog.Initials, recordSets)
               .item("Terminal").value = udtPharmacyLog.Terminal
               .item("Description").value = strDBName
               .item("Detail").value = udtPharmacyLog.Detail
               .item("NSVCode").value = udtPharmacyLog.NSVCode
            End With
         
            adoCmd.Execute , , adExecuteNoRecords
         
DataResume:
            If IsEmpty(adoCmd.Parameters("WPharmacyLogID").value) Then
               LogConversionError udtError, _
                      strSiteNumber, _
                      strDbConn, _
                      strFile, _
                      lngFilePos
            End If
            adoCmd.Parameters("WPharmacyLogID").value = Empty
         End If
      Wend
   End If
   
Cleanup:

   On Error Resume Next
   frmProgress.ProgressHide
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

DataError:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume DataResume
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function ConvertReports(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal strFileName As String, _
                               ByVal strReportNamePrefix As String, _
                               ByVal reportRoutineName As String, _
                               ByVal onlyIfExists As Boolean, _
                               ByVal strDbConn As String) As String
    Dim SiteNumber As Variant
    For Each SiteNumber In strSiteNumbers
        ConvertReport lngSessionID, CLng(SiteNumber), strDataDrive, strFileName, strReportNamePrefix, reportRoutineName, onlyIfExists, strDbConn
    Next
End Function

Private Function ConvertReport(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strFileName As String, _
                                      ByVal strReportNamePrefix As String, _
                                      ByVal reportRoutineName As String, _
                                      ByVal onlyIfExists As Boolean, _
                                      ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Convert Report
'
' Inputs:
'     lngSessionID:        Standard sessionid
'     strSiteNumber:       Site number
'     strDataDrive:        Drive for files
'     strFilename:         Filename
'     strReportNamePrefix: Prefix of the report in the DB
'     strDbConn:           Connection string
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  21May14 XN  Written 88857
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertReport"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim strReport As String
Dim lngFilePos As Long
Dim lngFound As Long
Dim strFile As String
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             strFileName)
                                    
   BuildV8RichTextDocumentAdoCmdObject strDbConn, _
                                       lngSessionID, _
                                       reportRoutineName, _
                                       adoCmd
                                
   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
                                
   On Error GoTo DataError
      
   If Not onlyIfExists Or Dir$(strFile) <> "" Then
    strReport = GetReport(strFile, strSiteNumber, lngFound)
   End If
      
    With adoCmd.Parameters
       .item("Description").value = strReportNamePrefix + " " + strSiteNumber
       .item("Detail").value = strReport
    End With
         
    adoCmd.Execute , , adExecuteNoRecords
         
Cleanup:

   On Error Resume Next
   
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
      
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Private Sub BuildV8TPNRxProformaAdoCmdObject(ByVal strDbConn As String, _
                                             ByVal lngSessionID As Long, _
                                             ByVal lngLocationID_Site As Long, _
                                             ByRef adoCmd As ADODB.Command, _
                                             ByRef adoCmd2 As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  23Jan12 CKJ  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildV8TPNRxProformaAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pPNRulePrescriptionProFormaInsert"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("RuleNumber", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("RuleType", adInteger, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 50, "")
      .Parameters.Append .CreateParameter("RuleSQL", adVarChar, adParamInput, 255, "")     'varchar(max) but filled from text(255)
      .Parameters.Append .CreateParameter("Critical", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PerKilo", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("InUse", adBoolean, adParamInput, , 0)
      .Parameters.Append .CreateParameter("PNCode", adVarChar, adParamInput, 8, "")        'was IngredientName in V8, now used for ingredient to product only
      .Parameters.Append .CreateParameter("Ingredient", adVarChar, adParamInput, 5, "")    'was IngredientAction in V8, now used for ingredient to product only
      .Parameters.Append .CreateParameter("Explanation", adVarChar, adParamInput, 255, "") 'varchar(1024) but filled from text(255)
      .Parameters.Append .CreateParameter("LastModDate", adDate, adParamInput, , Null)
      .Parameters.Append .CreateParameter("LastModUser", adVarChar, adParamInput, 3, "")   '** consider widening &/or EntityID
      .Parameters.Append .CreateParameter("LastModTerm", adVarChar, adParamInput, 15, "")  'was 8 in V8
      .Parameters.Append .CreateParameter("Info", adVarChar, adParamInput, 255, "")        'varchar(max) but filled from text(255)
      
      .Parameters.Append .CreateParameter("Volume_mL", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Nitrogen_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Glucose_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Fat_grams", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Sodium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Potassium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Calcium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Magnesium_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Zinc_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Phosphate_mmol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Selenium_nanomol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Copper_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("Iron_micromol", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("AqueousVitamins_mL", adDouble, adParamInput, , 0)
      .Parameters.Append .CreateParameter("LipidVitamins_mL", adDouble, adParamInput, , 0)
      
      .Parameters.Append .CreateParameter("PNRuleID", adInteger, adParamOutput, 4)
   End With

   Set adoCmd2 = New ADODB.Command

   With adoCmd2
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pV8PNRulePrescriptionProFormaDelete"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngLocationID_Site)
      .Parameters.Append .CreateParameter("RuleNumber", adInteger, adParamInput, , 0)
   End With

Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub
Private Sub OpenRandomFile(ByVal strDataPath As String, ByVal intRecordLen As Integer, intFileHandle As Integer)

Const cstrProcName = ".OpenRandomFile"

   On Error GoTo OpenFileErr
         
   intFileHandle = FreeFile
   Open strDataPath For Binary Access Read Write Shared As #intFileHandle
         
   On Error GoTo 0

Exit Sub

OpenFileErr:

   Err.Raise Err.Number, CLASS_NAME & cstrProcName, Err.Description
   
End Sub
Sub GetPointer(strFileName As String, lngPointer As Long, intIncrement As Integer)
'-----------------------------------------------------------------------------
'ASC 8 Nov 90       Reads pointer at beginning of RAM file
'
'
' If intIncrement =  0   reads pointer                       (i.e. inc = FALSE)
'              = -1  reads pointer and adds one and saves (i.e. inc = TRUE )
'              =  1   reads pointer and takes one and saves
'              =  2   writes pointer
'              =  3   reads pointer locks it
'              =  4   unlocks pointer
'
' 7Aug91 CKJ Proc moved to DFHL from Subpatme
'17Jun92 ASC seperate locking and unlocking added for order numbers
'21Dec93 CKJ/ASC inc=2 used to write NEW value, but return OLD value
'                         now writes NEW value and returns NEW value
'23Feb96 CKJ et al Corrected Lock range, removed intIncrement 3/4
'            Tidied as per DOS version

'mods needed
' - take whole structure for record one then take pointer
' - use of chan = 0 will only work while only one file in the system needs locking
'-----------------------------------------------------------------------------
Const cstrProcName = ".getpointer"

Dim p As pointertype

Dim intChan As Integer
Dim intRetries As Integer

Dim lngCurrentPointer As Long
Dim lngErrnum As Long

Dim udtError As udtErrorState

   Select Case intIncrement
      Case 3, 4
         MsgBox "Warning: Program Halted", "Corelib: GetPointer called with increment = 3 or 4"
         Exit Sub
      End Select

   OpenRandomFile strFileName, Len(p), intChan
   
   lngCurrentPointer& = lngPointer
   intRetries = 0

   Do
      On Error GoTo GetPointer_Err
      lngErrnum = 0
      Lock #intChan, 1 To 4
      If lngErrnum = 70 Then
            If intRetries < 5 Then
                  intRetries = intRetries + 1
                  Sleep 500
               Else
                  Err70msg lngErrnum, "Pointer"
               End If
         Else
            On Error GoTo 0
            intRetries = 0
            Do
               On Error GoTo GetPointer_Err
               lngErrnum = False
               Get #intChan, 1, p
               Err70msg lngErrnum, "Pointer record (read)"
            Loop While lngErrnum

            lngPointer = p.ptr

            If Abs(intIncrement) = 1 Then ' 6Aug91 CKJ Copes with inc/dec
                  lngPointer = lngPointer - intIncrement
                  p.ptr = lngPointer
                  Put #intChan, 1, p
                  'FlushBuffers intChan
               End If

            If intIncrement = 2 Then
                  p.ptr = lngCurrentPointer
                  Put #intChan, 1, p
                  'FlushBuffers intChan
                  lngPointer = lngCurrentPointer                 '21Dec93 CKJ Added
               End If

            Unlock #intChan, 1 To 4
         End If
   Loop Until intRetries = 0

Cleanup:
On Error Resume Next
   
   Close #intChan
   
On Error GoTo 0

Exit Sub

GetPointer_Err:
   lngErrnum = Err.Number

   CaptureErrorState udtError, CLASS_NAME, "GetPointer"
Resume Cleanup
  
End Sub

Private Sub Err70msg(ByVal lngErrnum As Long, strDescription As String)
'-----------------------------------------------------------------------------
' Test for Permission Denied error, and pop message if found
'21Feb91 CKJ Checks for error 63 & 70 now
'-----------------------------------------------------------------------------
Dim strMsg As String

   Select Case lngErrnum
      Case 70                                         ' permission denied
         MsgBox strDescription & " in use by another terminal", 0, "Paused"
         Sleep 1000
      Case 63                                         ' Bad Record Number
         strMsg = "Program paused - unable to access " & strDescription & Chr$(13)
         strMsg = strMsg & "The file is probably in use by another terminal."
         MsgBox strMsg, 0, "Paused"
         Sleep 1000
      End Select

End Sub
Public Sub GetSupplier(ByVal SiteNumber As Long, ByVal DataDrive As String, ByVal FilePosn As Long, ByRef sup As supplierstruct)

Const SUB_NAME = "GetSupplier"

Dim udtError As udtErrorState
Dim udtSupplier As supplierstruct

Dim strSupFilePath As String


   On Error GoTo ErrorHandler
   
   strSupFilePath = GenerateSupplierFilePath(SiteNumber, DataDrive)
   
   If FilePosn > -1 Then
      'udtSupplier = GetV85SupplierFromDisk(strSupFilePath, FilePosn)
      sup = GetV85SupplierFromDisk(strSupFilePath, FilePosn)
   Else
      'BlankSupplierStruct udtSupplier
      BlankSupplierStruct sup
   End If
   
   'StructToClass udtSupplier
   'udtSupplier
   ''mlngFilePosn = FilePosn
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError
   
Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub
Public Function GenerateSupplierFilePath(ByVal SiteNumber As Long, ByVal DataDrive As String) As String

Const SUB_NAME = "GenerateSupplierFilePath"

Const SUPPLIER_FILE_NAME = "\SUPFILE.V5"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler
   
   GenerateSupplierFilePath = DataDrive & "\DISPDATA." & Format$(SiteNumber, "000") & SUPPLIER_FILE_NAME
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   GenerateSupplierFilePath = ""
   Resume Cleanup
   
End Function

Public Function GetV85SupplierFromDisk(ByVal strSupFilePath As String, _
                                       ByVal lngFilePosn As Long, _
                                       Optional ByVal boolLock As Boolean = False) As supplierstruct

Const SUB_NAME = "GetV85SupplierFromDisk"
Const RETRY_LIMIT = 10

Dim udtError As udtErrorState
Dim udtSupplier As supplierstruct

Dim boolTrapError As Boolean
Dim intSupplierRecLen As Integer
Dim intRetries As Integer

Dim lngFirstByte As Long
Dim lngLastByte As Long

   On Error GoTo ErrorHandler
   
   mintFileHandle = OpenSupplierFile(strSupFilePath)
   
   CalculateByteNumbers Len(udtSupplier), lngFilePosn, lngFirstByte, lngLastByte
   
   intRetries = 0
   If boolLock Then
RetryLock:
      On Error GoTo LockErrorHandler
      Lock #mintFileHandle, lngFirstByte To lngLastByte
   End If
   
   intRetries = 0
RetryGet:
   On Error GoTo GetErrorHandler
   Get #mintFileHandle, lngFirstByte, udtSupplier
   
   GetV85SupplierFromDisk = udtSupplier
      
Cleanup:

   On Error Resume Next
   If Not boolLock Then CloseV8SupplierFile
   
   On Error GoTo 0
   BubbleOnError udtError
   
Exit Function

LockErrorHandler:

   boolTrapError = True
   
   If (Err.Number = 70) Or (Err.Number = 63) Then
      intRetries = intRetries + 1
      If (intRetries <= RETRY_LIMIT) Then boolTrapError = False
   End If
   
   If boolTrapError Then
      CaptureErrorState udtError, CLASS_NAME, SUB_NAME
      Resume Cleanup
   Else
      Sleep 100
      Resume RetryLock
   End If
   
GetErrorHandler:

   boolTrapError = True
   
   If (Err.Number = 70) Or (Err.Number = 63) Then
      intRetries = intRetries + 1
      If (intRetries <= RETRY_LIMIT) Then boolTrapError = False
   End If
   
   If boolTrapError Then
      CaptureErrorState udtError, CLASS_NAME, SUB_NAME
      Resume Cleanup
   Else
      Sleep 100
      Resume RetryGet
   End If

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, "GetPointer"
   Resume Cleanup
   
End Function
Public Sub BlankSupplierStruct(ByRef udtSupplier As supplierstruct)

Dim udtR As FileRecord

   udtR.record = ""
   LSet udtSupplier = udtR
   
End Sub

Private Function OpenSupplierFile(ByVal strSupFilePath As String) As Integer

Const SUB_NAME = "OpenSupplierFile"
Const RETRY_LIMIT = 10

Dim udtError As udtErrorState

Dim bTrapError As Boolean
Dim intFileHandle As Integer
Dim intRetries As Integer


   On Error GoTo ErrorHandler
   
   intFileHandle = FreeFile()
   
RetryOpen:
   
   Open strSupFilePath For Binary Access Read Write Shared As #intFileHandle

   OpenSupplierFile = intFileHandle
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   bTrapError = True
   If (Err.Number = 70) Or (Err.Number = 63) Then
      intRetries = intRetries + 1
      If (intRetries <= RETRY_LIMIT) Then bTrapError = False
   End If
   
   If bTrapError Then
      CaptureErrorState udtError, CLASS_NAME, SUB_NAME
      Resume Cleanup
   Else
      Sleep 100
      Resume RetryOpen
   End If
   
End Function
Private Sub CalculateByteNumbers(ByVal intStructLength As Integer, _
                                 ByVal lngRecordNumber As Long, _
                                 ByRef lngFirstByte As Long, _
                                 ByRef lngLastByte As Long)
                                 
Const SUB_NAME = "CalculateByteNumbers"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler
   
   lngFirstByte = (lngRecordNumber - 1) * intStructLength + 1
   lngLastByte = lngFirstByte - 1 + intStructLength
   
Cleanup:
                                 
   On Error GoTo 0
   BubbleOnError udtError
   
Exit Sub
   
ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                                 
End Sub

Private Sub CloseV8SupplierFile()

   On Error Resume Next
   Close #mintFileHandle
   mintFileHandle = -1
      
End Sub

Private Function FindUserID(ByVal Initials As String, ByRef recordSets As ADODB.Recordset) As Long
    FindUserID = 0
    
    recordSets.MoveFirst
    While Not recordSets.EOF
        If Initials = recordSets!Initials Then
            If FindUserID = 0 Then
                FindUserID = recordSets!EntityID
            Else
                FindUserID = 0
                Exit Function
            End If
        End If
        
        recordSets.MoveNext
    Wend
    
End Function

Public Function ConvertCrystalReports(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal strFileName As String, _
                               ByVal onlyIfExists As Boolean, _
                               ByVal strDbConn As String) As String
                               
'15Nov16 TH Written Based on rtf import TFS 157972
    Dim SiteNumber As Variant
    For Each SiteNumber In strSiteNumbers
        ConvertCrystalReports = ConvertCrystalReport(lngSessionID, CLng(SiteNumber), strDataDrive, strFileName, onlyIfExists, strDbConn) '  09Mar17 TH  Alow retrn of error msgs (TFS 178772)
    Next
End Function

Private Function ConvertCrystalReport(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strFileName As String, _
                                      ByVal onlyIfExists As Boolean, _
                                      ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Convert Crystal Report
'
' Inputs:
'     lngSessionID:        Standard sessionid
'     strSiteNumber:       Site number
'     strDataDrive:        Drive for files
'     strFilename:         Filename
'     onlyIfExists:        Not really used as yet
'     strDbConn:           Connection string
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  15Nov16 TH  Written based on Convert report TFS 157972
'  09Mar17 TH  Added crystal report file check (TFS 178772)
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertCrystalReport"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim strReport As String
Dim lngFilePos As Long
Dim lngFound As Long
Dim strFile As String
Dim lngLocationID_Site As Long
Dim adoConn As ADODB.Connection
Dim adoStream As ADODB.Stream

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             strFileName)
                             
   '09Mar17 TH Added purely for crystal report file check (TFS 178772)
   If Not fileexists(strFile) Then
      'MsgBox "File missing from import drive : " & strFile
      ConvertCrystalReport = FormatBrokenRulesXML(FormatBrokenRuleXML("FILE_MISSING", "File missing from import drive : " & strFile)) '  09Mar17 TH  Added crystal report file check (TFS 178772)
      Exit Function
   End If
   
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildPharmacyCrystalReportAdoCmdObject strDbConn, _
                                       lngSessionID, _
                                       lngLocationID_Site, _
                                       adoCmd
                                    
   'Use a stream to open and get the file contents ready for Export to DB
   Set adoStream = New ADODB.Stream
   adoStream.Type = adTypeBinary
 
   
 
   adoStream.open
   adoStream.LoadFromFile strFile


   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
                                
   On Error GoTo DataError
      
   If Not onlyIfExists Or Dir$(strFile) <> "" Then
    strReport = GetReport(strFile, strSiteNumber, lngFound)
   End If
      
    With adoCmd.Parameters
       .item("Name").value = Left$(strFileName, Len(strFileName) - 4) 'Remove the extension
       .item("Report").value = adoStream.Read
    End With
         
    adoCmd.Execute , , adExecuteNoRecords
    
Cleanup:

   On Error Resume Next
   
   adoCmd.ActiveConnection.Close
   adoStream.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
   Set adoStream = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Sub BuildPharmacyCrystalReportAdoCmdObject(ByVal strDbConn As String, _
                                                ByVal lngSessionID As Long, _
                                                ByVal lngSiteID As Long, _
                                                ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose: Build parameters for pPharmacyCrystalReportInsert (converting .rpt files)
'
' Inputs:
'     strDbConn :   Connection string
'     lngSessionID: Session ID
'     adoCmd:       Command
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Nov16 TH Written Based on rtf Conversion routines TFS 157972
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildPharmacyCrystalReportAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pPharmacyCrystalReportWrite"                'use standard SP
      .Parameters.Append .CreateParameter("CurrentSessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("Location_SiteID", adInteger, adParamInput, 4, lngSiteID)
      .Parameters.Append .CreateParameter("Name", adVarChar, adParamInput, 8000, "")
      .Parameters.Append .CreateParameter("Report", adVarBinary, adParamInput, -1, Null)
      .Parameters.Append .CreateParameter("Updated", adDate, adParamInput, 8, Now)
      '.Parameters.Append .CreateParameter("PharmacyCrystalReportID", adInteger, adParamOutput, 4)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub

Private Sub BuildPharmacyRTFReportAdoCmdObject(ByVal strDbConn As String, _
                                                ByVal lngSessionID As Long, _
                                                ByVal lngSiteID As Long, _
                                                ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose: Build parameters for pPharmacyRTFReportInsert (converting .rtf files)
'
' Inputs:
'     strDbConn :   Connection string
'     lngSessionID: Session ID
'     adoCmd:       Command
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  11Nov16 TH Written Based on rtf Conversion routines TFS 157972
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildPharmacyRTFReportAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pPharmacyRTFReportWrite"                'use standard SP
      .Parameters.Append .CreateParameter("CurrentSessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("Location_SiteID", adInteger, adParamInput, 4, lngSiteID)
      .Parameters.Append .CreateParameter("Name", adVarChar, adParamInput, 255, "")
      .Parameters.Append .CreateParameter("Report", adVarChar, adParamInput, -1, Null)
      .Parameters.Append .CreateParameter("Updated", adDate, adParamInput, 8, Now)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub

Public Function ConvertPharmacyRTFReports(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal onlyIfExists As Boolean, _
                               ByVal strDbConn As String) As String
                               
'05Dec16 TH Written Based loosely on rtf import TFS 157969

Dim SiteNumber As Variant
Dim strFile As String
Dim strDirFile As String
Dim fld As Folder
Dim fil As File
Dim fso As New FileSystemObject
Dim udtError As udtErrorState
Const SUB_NAME = "ConvertPharmacyRTFReports"
   
   On Error GoTo ErrorHandler
   'Loop through Each site
   For Each SiteNumber In strSiteNumbers
      'Loop through dispdata and select the rtfs for import
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3)
      

      Set fld = fso.GetFolder(strDirFile)
      For Each fil In fld.Files
         If LCase$(Right$(fil.name, 3)) = "rtf" Then
            'Here we do the actual covert
            ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, fil.name, strDirFile & "\" & fil.name, onlyIfExists, strDbConn
         End If
      Next
      
      'Now we need to check for anything in the worksheets folder
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3) & "\WKSHEETS"
      

      Set fld = fso.GetFolder(strDirFile)
      For Each fil In fld.Files
         If LCase$(Right$(fil.name, 3)) = "rtf" Then
            'Here we do the actual covert
            ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, fil.name, strDirFile & "\" & fil.name, onlyIfExists, strDbConn
         End If
      Next
      'Now we need to check for anything in the worksheets Archive folder
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3) & "\WKSHEETS\Archive"
      

      Set fld = fso.GetFolder(strDirFile)
      For Each fil In fld.Files
         If LCase$(Right$(fil.name, 3)) = "rtf" Then
            'Here we do the actual covert
            ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, fil.name, strDirFile & "\" & fil.name, onlyIfExists, strDbConn
         End If
      Next
      
      'Now we need to check for anything in the worksheets Draft folder
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3) & "\WKSHEETS\Draft"
      

      Set fld = fso.GetFolder(strDirFile)
      For Each fil In fld.Files
         If LCase$(Right$(fil.name, 3)) = "rtf" Then
            'Here we do the actual covert
            ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, fil.name, strDirFile & "\" & fil.name, onlyIfExists, strDbConn
         End If
      Next
   Next
   
Cleanup:

   On Error Resume Next
   
   Set fld = Nothing
   Set fso = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Private Function ConvertPharmacyRTFReport(ByVal lngSessionID As Long, _
                                      ByVal strSiteNumber As String, _
                                      ByVal strDataDrive As String, _
                                      ByVal strFileName As String, _
                                      ByVal strPathFileName As String, _
                                      ByVal onlyIfExists As Boolean, _
                                      ByVal strDbConn As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:  Convert Crystal Report
'
' Inputs:
'     lngSessionID:        Standard sessionid
'     strSiteNumber:       Site number
'     strDataDrive:        Drive for files
'     strFilename:         Filename
'     onlyIfExists:        Not really used as yet
'     strDbConn:           Connection string
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  15Nov16 TH  Written based on Convert report TFS 157969
'10Feb17 TH  Use old Load routine in order to preserve file as per standard system (TFS 176550)
'27Mar17 TH  Fix to ensure filename isnt interpreted in path (TFS 180785)
'----------------------------------------------------------------------------------

Const SUB_NAME = "ConvertPharmacyRTFReport"

Dim udtError As udtErrorState
                               
Dim adoCmd As ADODB.Command

Dim intSiteNumber As Integer

Dim strReport As String
Dim lngFilePos As Long
Dim lngFound As Long
Dim strFile As String
Dim lngLocationID_Site As Long
Dim adoConn As ADODB.Connection
Dim adoStream As ADODB.Stream

   On Error GoTo ErrorHandler

   intSiteNumber = Val(strSiteNumber)
   
   'strFile = BuildV8FilePath(strDataDrive, _
                             eDispdata, _
                             strSiteNumber, _
                             strFileName)
                             
   strFile = strPathFileName
   lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           intSiteNumber)
                                           
   BuildPharmacyRTFReportAdoCmdObject strDbConn, _
                                       lngSessionID, _
                                       lngLocationID_Site, _
                                       adoCmd
                                    
   'Use a stream to open and get the file contents ready for Export to DB
   'Set adoStream = New ADODB.Stream
   'adoStream.Type = adTypeBinary
 
   
 
   'adoStream.open
   'adoStream.LoadFromFile strFile


   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
                                
   On Error GoTo DataError
      
   If Not onlyIfExists Or Dir$(strFile) <> "" Then
    'strReport = GetReport(strFile, strSiteNumber, lngFound)
    GetTextFile strFile, strReport, 0 '10Feb17 TH Replace above in order to preserve file as per standard system (TFS 176550)
   End If
      
    'If InStr(LCase$(strPathFileName), "\wksheets\draft") > 0 Then
    If InStr(LCase$(strPathFileName), "\wksheets\draft\") > 0 Then  '27Mar17 TH Altered these to ensure filename isnt interpreted by path (TFS 180785)
      strFileName = "WRKSHEET|DRAFT|" & strFileName
    'ElseIf InStr(LCase$(strPathFileName), "\wksheets\archive") > 0 Then
    ElseIf InStr(LCase$(strPathFileName), "\wksheets\archive\") > 0 Then
      strFileName = "WRKSHEET|ARCHIVE|" & strFileName
    'ElseIf InStr(LCase$(strPathFileName), "\wksheets") > 0 Then
    ElseIf InStr(LCase$(strPathFileName), "\wksheets\") > 0 Then
      strFileName = "WRKSHEET|" & strFileName
    'ElseIf InStr(LCase$(strPathFileName), "\pil") > 0 Then
    ElseIf InStr(LCase$(strPathFileName), "\pil\") > 0 Then
      strFileName = "PIL|" & strFileName
    End If
    
    With adoCmd.Parameters
       .item("Name").value = Left$(strFileName, Len(strFileName) - 4) 'Remove the extension
       '.item("Report").value = adoStream.Read
       .item("Report").value = strReport
    End With
         
    adoCmd.Execute , , adExecuteNoRecords
    
Cleanup:

   On Error Resume Next
   
   adoCmd.ActiveConnection.Close
   adoStream.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
   'Set adoStream = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

DataError:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function ConvertPharmacyPILs(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal onlyIfExists As Boolean, _
                               ByVal strDbConn As String) As String
                               
'08Jan17 TH Written Based on ConvertPharmacyRTFReports TFS 157969
'27Mar17 TH Added check on PIL directory (TFS 178772)
'28Mar17 TH check directory not file (TFS 178772)

Dim SiteNumber As Variant
Dim strFile As String
Dim strDirFile As String
Dim fld As Folder
Dim fil As File
Dim fso As New FileSystemObject
Dim udtError As udtErrorState
Const SUB_NAME = "ConvertPharmacyPILs"
   
   On Error GoTo ErrorHandler
   'Loop through Each site
   For Each SiteNumber In strSiteNumbers
      'Loop through dispdata and select the rtfs for import
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3) & "\PIL"
      
      'If Fileexists(strDirFile) Then  '27Mar17 TH Added check on PIL directory (TFS 178772)
      If DirExists(strDirFile) Then  '28Mar17 TH check directory not file (TFS 178772)
         Set fld = fso.GetFolder(strDirFile)
         For Each fil In fld.Files
            If LCase$(Right$(fil.name, 3)) = "pil" Then
               'Here we do the actual covert - I think we can use the standard rtf one (as its is essentially rtf.
               ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, fil.name, strDirFile & "\" & fil.name, onlyIfExists, strDbConn
            End If
         Next
      Else '27Mar17 TH Added check on PIL directory (TFS 178772)
         MsgBox "Cannot Convert Patient Information Leaflets for site number " & SiteNumber & ". PIL Repository does not exist  (" & strDirFile & ")"
         ' Just skip the site, keep in loop
      End If
   Next
   
Cleanup:

   On Error Resume Next
   
   Set fld = Nothing
   Set fso = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ConvertLicenseFile(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal strDbConn As String) As String
                               
'12Jan17 TH Written (TFS 156988)

Dim SiteNumber As Variant
Dim strFile As String
Dim udtError As udtErrorState
Dim pathfileext$, success%, tmp$, ret$, posn%, posn1%
Dim adoCmd As ADODB.Command
Dim lngLocationID_Site As Long
Dim intLoop As Integer
Dim strValue As String

Const SUB_NAME = "ConvertLicenseFile"
   
   On Error GoTo ErrorHandler
   'Loop through Each site
   
   BuildV8ConfigAdoCmdObject strDbConn, _
                             lngSessionID, _
                             adoCmd
                             
   For Each SiteNumber In strSiteNumbers
      
      lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           Val(SiteNumber))
                                                                      
      adoCmd.Parameters("locationid_site").value = lngLocationID_Site
      
      strFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3) & "\Ascribe.lx"
      For intLoop = 0 To 2
         If fLX("MainScreen.MnuMediate." & CStr(intLoop), 0, strFile) = "1" Then
            strValue = "Y"
         Else
            strValue = "N"
         End If
         With adoCmd
                  .Parameters("category").value = "D|winord"
                  .Parameters("section").value = "License"
                  .Parameters("key").value = "MnuMediate" & CStr(intLoop)
                  .Parameters("value").value = CreateConfigValue(strValue)
                  
                  .Execute , , adExecuteNoRecords
                  
         End With
      Next
      
      If fLX("MainScreen.mnuEdi.0", 0, strFile) = "1" Then
         strValue = "Y"
      Else
         strValue = "N"
      End If
      With adoCmd
               .Parameters("category").value = "D|winord"
               .Parameters("section").value = "License"
               .Parameters("key").value = "MnuEdi0"
               .Parameters("value").value = CreateConfigValue(strValue)
               
               .Execute , , adExecuteNoRecords
               
      End With
     

      
   Next
   
Cleanup:

   On Error Resume Next
   
   
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Private Function fLX(LinkID$, Token&, pathfileext$) As String
'13Jan17 TH  Ported and tinkered with to allow the license file conversion (TFS 156988)

'Licence control procedure
' All handling of the licence file is done here
' - read once, hold as static data & hand out data on demand
' Call at start of program to fill    Ret$ = Flx("", Token&)
' Ret$ is blank on first call, Token& is not used yet.
' NB if routine fails to read a valid set of data program ends.

'Once read into Txt$, each entry is of the format [10]item=value[13]

Dim txt$
Dim success%, tmp$, ret$, posn%, posn1%
            
   success = False
   ret$ = ""
   If txt$ = "" Then                                           'not already loaded
   'pathfileext$ = dispdata$ & "\ascribe.lx"
   'If FileExists(pathfileext$) Then                      'file found
      GetTextFile pathfileext$, txt$, success
      If success Then
      decodehex txt$
      txt$ = Chr$(10) & txt$ & Chr$(13)
      'encodehex Txt$
      'PutTextFile pathfileext$, Txt$, success
      End If
      'End If
   Else
      success = True
   End If

   If success And LinkID$ <> "" Then
    tmp$ = Chr$(10) & LinkID$ & "="
    posn = InStr(1, txt$, tmp$, 1)                        'case independent
    If posn Then
          posn1% = InStr(posn + Len(tmp$), txt$, Chr$(13))      'look for end of string
          fLX$ = Mid$(txt$, posn + Len(tmp$), posn1 - Len(tmp$) - posn)
       End If
      End If

End Function
Sub GetTextFile(pathfileext$, txt$, success%)
'13Jan17 TH  Ported and tinkered with to allow the license file conversion (TFS 156988)

Dim Chan%

   success = False
   On Error GoTo GetTextfile_OpenErr
   Chan = FreeFile
   Open pathfileext$ For Binary Access Read Shared As #Chan
   'TrackOpenedFiles chan, pathfileext$, "GetTextFile"         '27May04 CKJ
   On Error GoTo GetTextfile_Err
   'If LOF(chan) < 32768 Then                                  'file is not too long to read
   If LOF(Chan) < 10000000 Then           '03Jul13 TH Extend limit (TFS 67988)
         txt$ = Space$(LOF(Chan))
         Get #Chan, , txt$
         success = True
   Else
      MsgBox "File : " & pathfileext$ & " is too long to read and cannot be loaded"  '03Jul13 TH Added msg in nlikely event this cant be loaded
   End If

GetTextfile_CloseAndExit:                                     '11Mar98 CKJ
   On Error Resume Next
   Close #Chan
   'TrackOpenedFiles chan, "", ""                              '27May04 CKJ
GetTextfile_Exit:
   On Error GoTo 0
Exit Sub

GetTextfile_OpenErr:
Resume GetTextfile_Exit

GetTextfile_Err:                                              '11Mar98 CKJ
Resume GetTextfile_CloseAndExit

End Sub
Sub decodehex(passw As String)
'-----------------------------------------------------------------------------
'30Oct94 CKJ Written. Returns an encoded hex string
'-----------------------------------------------------------------------------
'13Jan17 TH  Ported  to allow the license file conversion (TFS 156988)

Dim pasin As String, plen%, iByte%

   plen = Len(passw) \ 4
   pasin = passw
   passw = ""
   If plen Then
         For iByte = 1 To plen * 4 Step 4
            passw = passw & Chr$((((Val("&h" & Mid$(pasin, iByte, 2)) * 2) Mod 256) And &HAA) Or (Val("&h" & Mid$(pasin, iByte + 2, 2)) And &H55))
         Next
      End If

End Sub

Function fileexists(drvpthfilext$) As Boolean
'-----------------------------------
'09Mar17 TH Ported purely for crystal report file check (TFS 178772)


Dim complete%, failed%, filespec$, msg$, button%, NumOfTimes%, intButtons As Integer
Dim iChan As Integer, strError As String
Dim ErrNum As Long

   '20Jan95 CKJ Don't check for Std I/O
   Select Case UCase$(Trim$(drvpthfilext$))
      Case "PRN", "PRN:", "LPT1", "LPT1:", "LPT2", "LPT2:", "LPT3", "LPT3:"
         fileexists = True
      Case ""
         On Error GoTo FileExists_Err
         Error 255

      Case Else
         Do
            complete = False
            failed = False
            filespec$ = ""
            On Error GoTo FileExists_Err
            filespec$ = Dir$(drvpthfilext$)
            On Error GoTo 0
            If Not failed Then
                  fileexists = Not (filespec$ = "")
                  complete = True
               End If
         Loop Until complete
      End Select
Exit Function

FileExists_Err:
   
   failed = True
Resume Next

End Function

Function DirExists(ByVal drvpth$) As Boolean
'-----------------------------------------------------------------------------
'28Mar17 TH Ported Across for use in PIL checking (TFS 178772)

Dim status%, DirName$, msg$, mousewas%
Dim ErrNum As Long

   status = False
   mousewas = Screen.MousePointer
   If drvpth$ <> "" Then
         DirName = ""
         If Right$(drvpth$, 1) = "\" Then                                'path of C:\orderlog\
               drvpth$ = Left$(drvpth$, Len(drvpth$) - 1)                'remove  C:\orderlog
               If Right$(drvpth$, 1) = ":" Then drvpth$ = drvpth$ & "\"  'but is needed for C:\
            End If
         On Error GoTo DirExists_Err
         Screen.MousePointer = 11
         DirName = Dir$(drvpth$, 16)
         If DirName <> "" Then
               If (GetAttr(drvpth$) And 16) = 16 Then
                     status = True
                  End If
            End If
      Else
         On Error GoTo DirExists_Err
         Error 255
      End If

direxists_resume:
   On Error GoTo 0
   Screen.MousePointer = mousewas
   DirExists = status
Exit Function

DirExists_Err:
   Screen.MousePointer = 0             '29Jul98 CKJ Note: appears to be ignored here

   ErrNum = Err
   'If errnum = 76 Then Resume Next            ' 9Apr96 CKJ Added. 76=Path not found
   If ErrNum = 76 Then Resume direxists_resume '29Jul98 CKJ Corrected

   Select Case ErrNum
      Case 57:   msg$ = " 57 Device I/O error"
      Case 64:   msg$ = " 64 Bad file name"
      Case 68:   msg$ = " 68 device unavailable"
      Case 71:   msg$ = " 71 disk not ready"
      Case 255:  msg$ = " 255 file name is null"
      Case Else: msg$ = " Error number" + Str$(ErrNum)
      End Select
   msg$ = "Error reading directory:  " & drvpth$ & Chr(13) & Chr(13) & msg$ & Chr(13) & "Inform System Supervisor"
   MsgBox msg$
   
Resume Next

End Function

Public Function ConvertPharmacyROQROLTemplates(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal strDbConn As String) As String
                               
'16May17 TH ROQROL CSV Template import (TFS 174881)

Dim SiteNumber As Variant
Dim strFile As String
Dim strDirFile As String
Dim fld As Folder
Dim fil As File
Dim fso As New FileSystemObject
Dim udtError As udtErrorState
Const SUB_NAME = "ConvertPharmacyROQROLTemplates"
Dim strHeader As String
Dim lngLocationID_Site As Long
Dim strData As String
   
   On Error GoTo ErrorHandler
   'Loop through Each site
   For Each SiteNumber In strSiteNumbers
    lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                           strDbConn, _
                                           CInt(SiteNumber))
      'Loop through dispdata and select the rtfs for import
      strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3)
      strHeader = ReadWConfiguration(lngSessionID, strDbConn, lngLocationID_Site, "D|Winord", "RoqAndRol", "CSVHeaderFile", "HdrRqRl.txt")
      strData = ReadWConfiguration(lngSessionID, strDbConn, lngLocationID_Site, "D|Winord", "RoqAndRol", "CSVFormatFile", "CSVRqRl.txt")
      ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, strHeader, strDirFile & "\" & strHeader, 0, strDbConn
      ConvertPharmacyRTFReport lngSessionID, CLng(SiteNumber), strDataDrive, strData, strDirFile & "\" & strData, 0, strDbConn
      
   Next
   
Cleanup:

   On Error Resume Next
   
   Set fld = Nothing
   Set fso = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Function ReadWConfiguration(ByVal SessionID As Long, ByVal strDbConn As String, ByVal lngSiteID As Long, ByVal strCategory As String, ByVal strSection As String, ByVal strKeyName As String, ByVal strDefault As String) As String
'16May17 TH Added ROQROL CSV Template import (TFS 174881)

Dim rs As ADODB.Recordset
Dim strResult As String
Dim adoconfigCmd As ADODB.Command
Dim adoConn As ADODB.Connection
Dim lcludtError As udtErrorState
Const SUB_NAME = "ReadWConfiguration"

On Error GoTo 0

strResult = strDefault

Set adoConn = New ADODB.Connection
adoConn.ConnectionString = strDbConn
adoConn.open
Set adoconfigCmd = New ADODB.Command

    With adoconfigCmd

    Set .ActiveConnection = adoConn
     .CommandType = adCmdStoredProc
     .CommandText = "pWConfigurationSelectValue"
     .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, SessionID)
     .Parameters.Append .CreateParameter("locationid_site", adInteger, adParamInput, 4, lngSiteID)
    
     .Parameters.Append .CreateParameter("Category", adVarChar, adParamInput, 255, strCategory)
     .Parameters.Append .CreateParameter("section", adVarChar, adParamInput, 255, strSection)
     .Parameters.Append .CreateParameter("Key", adVarChar, adParamInput, 255, strKeyName)
      End With
               
    'Set rs = .Execute
    '.Execute
    On Error GoTo 0
    Set rs = New ADODB.Recordset
    rs.open adoconfigCmd, , adOpenStatic, adLockUnspecified
    'rs.Requery
       
    If Not (rs Is Nothing) Then
         If rs.RecordCount > 0 Then
         'rs.MoveFirst
         strResult = Trim$(CStr(rs!value))
         'Take off the inverted commas
         strResult = Left(strResult, Len(strResult) - 1)
         strResult = Right(strResult, Len(strResult) - 1)
        
        End If
    End If

    rs.Close
    Set rs = Nothing
    DoEvents
       
   
            

ReadWConfiguration = strResult

Cleanup:

   On Error Resume Next
   
   If Not adoConn Is Nothing Then
      If adoConn.State = adStateOpen Then adoConn.Close
      Set adoConn = Nothing
   End If
   
   If Not adoconfigCmd Is Nothing Then
      Set adoconfigCmd.ActiveConnection = Nothing
      Set adoconfigCmd = Nothing
   End If
   
   On Error GoTo 0
   BubbleOnError lcludtError

Exit Function

ErrorHandler:

   CaptureErrorState lcludtError, CLASS_NAME, SUB_NAME
   Resume Cleanup


End Function

Public Function ConvertPharmacyBackground(ByVal lngSessionID As Long, _
                               ByRef strSiteNumbers() As String, _
                               ByVal strDataDrive As String, _
                               ByVal strDbConn As String) As String
                               
'22May17 TH Written for background picture import (TFS 174888)
'28May17 TH Overhauled as cant use binary data. Now use text (base64 encoding) dont bother using stream

Dim SiteNumber As Variant
Dim strFile As String
Dim strDirFile As String
Dim udtError As udtErrorState
Const SUB_NAME = "ConvertPharmacyBackground"
Dim strHeader As String
Dim lngLocationID_Site As Long
Dim strBackground As String
Dim adoStm As ADODB.Stream
Dim adoCmd As ADODB.Command
Dim strImage As String
Dim fileNum As Integer
  Dim bytes() As Byte
   
    On Error GoTo ErrorHandler
    'Loop through Each site
    For Each SiteNumber In strSiteNumbers
        lngLocationID_Site = FindSiteLocationID(lngSessionID, _
                                             strDbConn, _
                                             CInt(SiteNumber))
        'Loop through dispdata and select the pictures for import from existing settings
        strDirFile = strDataDrive & "\Dispdata." & Right$("000" & CStr(SiteNumber), 3)
        strBackground = ReadWConfiguration(lngSessionID, strDbConn, lngLocationID_Site, "D|SiteInfo", "", "BackgroundImageFile", "")
        If Trim$(strBackground) <> "" Then
            'OK now we need to load the image from the file into an ado stream, then we can add this to the adocmd for transport
            Set adoCmd = New ADODB.Command
                                           
            BuildPharmacyImageAdoCmdObject strDbConn, _
                                       lngSessionID, _
                                       strBackground, _
                                       lngLocationID_Site, _
                                       adoCmd
                                       
            'Set adoStm = New ADODB.Stream
            'With adoStm
            '    .Type = adTypeBinary
            '    .open
            '    .LoadFromFile strDirFile & "\" & strBackground
            'End With
            'adoCmd.Parameters("Image") = adoStm.Read(adReadAll)
            'strImage = Base64EncodeString(adoStm.Read(adReadAll))
            'Decide to just read the file and not use the stream. Needs to go through encoding now anyway.
            fileNum = FreeFile
            Open strDirFile & "\" & strBackground For Binary As fileNum
            ReDim bytes(LOF(fileNum) - 1)
            Get fileNum, , bytes
            Close fileNum
            strImage = EncodeBase64(bytes)
            adoCmd.Parameters("Image") = strImage 'encodeB64(adoStm.Read(adReadAll))
            adoCmd.Execute , , adExecuteNoRecords
            
            'adoStm.Close
            'Set adoStm = Nothing
            
            adoCmd.ActiveConnection.Close
            Set adoCmd.ActiveConnection = Nothing
            Set adoCmd = Nothing
          
        End If
      
    Next
   
Cleanup:

   On Error Resume Next
   adoCmd.ActiveConnection.Close
   Set adoCmd.ActiveConnection = Nothing
   Set adoCmd = Nothing
   'If Not adoStm Is Nothing Then
   '   adoStm.Close
   '   Set adoStm = Nothing
   'End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function
   
ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Sub BuildPharmacyImageAdoCmdObject(ByVal strDbConn As String, _
                                                ByVal lngSessionID As Long, _
                                                ByVal StrImageName As String, _
                                                ByVal lngSiteID As Long, _
                                                ByRef adoCmd As ADODB.Command)
'----------------------------------------------------------------------------------
'
' Purpose: Build parameters for pV8WPharmacyLogInsert (converting labutils)
'
' Inputs:
'     strDbConn :   Connection string
'     lngSessionID: Session ID
'     routineName:  Name of the routine stored in the Routine table used to populate the report
'     adoCmd:       Command
'
' Outputs:
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  21May14 XN  Written 88857
'----------------------------------------------------------------------------------
Const SUB_NAME = "BuildPharmacyImageAdoCmdObject"

Dim udtError As udtErrorState
Dim adoConn As ADODB.Connection

   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pPharmacyImageWrite"                'use standard SP
      .Parameters.Append .CreateParameter("CurrentSessionID", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("SiteID", adInteger, adParamInput, 4, lngSiteID)
      .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 50, StrImageName)
      .Parameters.Append .CreateParameter("Image", adVarChar, adParamInput, -1, "")
      ''.Parameters.Append .CreateParameter("PharmacyImageID", adInteger, adParamOutput, 4)
   End With
      
Cleanup:
   On Error Resume Next
   Set adoConn = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
Exit Sub

ErrorHandler:
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
Resume Cleanup
  
End Sub

Private Function EncodeBase64(ByRef arrData() As Byte) As String

'28May17 TH Use standard encoding / decoding routines

    Dim objXML As MSXML2.DOMDocument
    Dim objNode As MSXML2.IXMLDOMElement
    
    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument
    
    ' byte array to base64
    Set objNode = objXML.createElement("b64")
    objNode.dataType = "bin.base64"
    objNode.nodeTypedValue = arrData
    EncodeBase64 = objNode.Text

 
    Set objNode = Nothing
    Set objXML = Nothing

 

End Function

 

Private Function DecodeBase64(ByVal strData As String) As Byte()

'28May17 TH Use standard encoding / decoding routines

    Dim objXML As MSXML2.DOMDocument
    Dim objNode As MSXML2.IXMLDOMElement
    
    ' help from MSXML
    Set objXML = New MSXML2.DOMDocument
    Set objNode = objXML.createElement("b64")
    objNode.dataType = "bin.base64"
    objNode.Text = strData
    DecodeBase64 = objNode.nodeTypedValue
    
    Set objNode = Nothing
    Set objXML = Nothing

 

End Function
   
