Attribute VB_Name = "Module5"
Option Explicit
DefInt A-Z   '01Jun02 ALL/ATW
'24Apr02 ATW Module Supporting Hierarchical To-Follows report
' #55445

'09May02 ATW Enhancements to support multiple lists per report
'28Jun02 ATW Improved handling of empty order lists (previously generated anonymous error, now properly generates empty reports)
'            N.B. - you get crappy reports unless the drugfile is properly indexed, because most elements of these reports are linked
'                    on NSVCode, and these get read from the drug records for the most part - so if the drug index is off, wrong NSVCode gets used.
'              GetXXX routines - removed internal count var, using module level vars.
'              ItemGetIndex    - uses module level counts instead of array bounds.
'22Aug02 ATW Moved HeaderFromLayout, TagDescription and TrimToRTFTable out into library module (used in invoice printing routine in shell)
'06Dec16 TH  ToFollowReport2: Replaced RTF (TFS 157969)
'04Jan17 TH  ToFollowReport2: Use Local File Parsing (Hosted) (TFS 157969)

Type ListElement
   title As String
   Item As String             ' The item to list
   LinkedItem As String       ' Linked item
   LinkedItem2 As String
   Format As String           ' The format to use for each line
   SortBy As String           ' The sort key to use
   FilterBy As String         ' The filter key to use
   Splitter As String         ' Splitter to use where sub-reports exist
   EmptyLine As String        ' The line to use if there are no items to report
   ReportCount As Integer     ' The number of sub-reports
   ReportID(5) As Integer     ' The indices of those sub reports
   Footer As String
   name As String             ' Name of the list (for header selection)
End Type


Type ReportElement
   title As String            ' The report title
   Footer As String           ' Line to display when report is over
   ListID(0 To 5) As Integer  ' The indices of the lists this report uses
   ListCount As Integer       ' 09May02 ATW added counter
   CurrentListID As Integer   ' 09May02 ATW Supports linking of lists in subreports
End Type

' Types used for sorting the reports

Type IndexElement
   id As Integer
   SortKey As String * 16
   FilterKey As String * 16
End Type

Type SortElement
   Item As String * 34
End Type

' XML Tags used by report schema

Const TAG_LIST = "List"
Const TAG_REPORT = "Report"
Const TAG_TITLE = "Title"
Const TAG_ITEM = "Item"
Const TAG_LINKEDITEM = "LinkedItem"
Const TAG_FORMAT = "Format"
Const TAG_SPLITTER = "Splitter"
Const TAG_EMPTYLINE = "EmptyLine"
Const TAG_FOOTER = "Footer"
Const TAG_SORTBY = "SortBy"
Const TAG_FILTERBY = "FilterBy"
Const TAG_NAME = "Name"

' Item identifiers

Const ITEM_REQUISITION = "Requisition"
Const ITEM_SUPPLIER = "Supplier"
Const ITEM_ORDER = "Order"
Const ITEM_WARD = "Ward"
Const ITEM_DRUG = "Drug"

' Item keys

Const KEY_NSVCODE = "NSVCode"
Const KEY_SUPPLIER = "SupCode"
Const KEY_DESCRIPTION = "Description"

' Heap items

Const REPORT_ORDERCOUNT = "rOrderCount"
Const REPORT_REQCOUNT = "rReqCount"
Const REPORT_WARDCOUNT = "rWardCount"
Const REPORT_SUPPLIERCOUNT = "rSupplierCount"
Const REPORT_DRUGCOUNT = "rDrugCount"

Dim m_blnReqsLoaded As Integer
Dim m_aRequisition() As orderstruct  ' Cache of all the requisitions
Dim m_intReqCount As Integer

Dim m_blnOrdersLoaded As Integer
Dim m_aOrder() As orderstruct        ' Cache of all the orders
Dim m_intOrderCount As Integer

Dim m_blnDrugsLoaded As Integer
Dim m_aDrug() As DrugParameters      ' Cache of the drugs
Dim m_intDrugCount As Integer

Dim m_blnWardsLoaded As Integer
Dim m_aWard() As supplierstruct      ' Cache of the wards
Dim m_intWardcount As Integer

Dim m_blnSuppliersLoaded As Integer
Dim m_aSupplier() As supplierstruct  ' Cache of the suppliers
Dim m_intSupplierCount As Integer

' Used for XML parsing
Dim m_strXML As String
Dim m_intXmlPointer As Integer

' The ID of the root report
Dim m_intRootReportID As Integer

' Array of the reports
Dim m_intReportCount As Integer
Dim m_aReport() As ReportElement
' Array of the lists
Dim m_intListCount As Integer
Dim m_aList() As ListElement

' Heaps
'Dim m_intHeaderHeap As Integer          '22Aug02 ATW Localised to HeaderFromLayout so it can move out into a libfiles module
Dim m_intReportHeap As Integer

' Output file channel
Dim m_intReportFile As Integer

Private Sub BuildReportStructure()
'26Apr02 ATW
'  Description : Build the report structure from the loaded XML
'

Dim isText As Integer
Dim isClose As Integer

   If Not (NextTag(isText, isClose) = TAG_REPORT) Then
         Error 10001
      End If
      
   m_intReportCount = 0
   m_intListCount = 0

   m_intRootReportID = NewReportElement()
   
   ReportElementFromXML m_aReport(m_intRootReportID)

End Sub

Sub CacheToFollowData()
'26Apr02 ATW
'  Description :  Build a cache of all the relevant data
'

' Get the to-follow reqs
   GetReqsToFollow
' build an array of wards that requisitioned them
   GetToFollowWards
' build an array of drugs that they cover
   GetToFollowDrugs
' build an array of outstanding orders for those drugs
   GetToFollowOrders
' build an array of outstanding suppliers for those orders
   GetToFollowSuppliers

End Sub

Private Function DrugKey(drug As DrugParameters, ByVal KeyName As String) As String
'26Apr02 ATW
'  Description :  Return a value to be used as a key from a DrugParameters type
'
'  Input :     Drug     ;  DrugParameters structure
'              KeyName  ;  The name of the key we want
'
'  OutPut:     Return   ;  The value of that key
Dim strOut As String

   Select Case KeyName
      Case KEY_NSVCODE
         DrugKey = drug.SisCode
      Case KEY_DESCRIPTION
         'strOut = drug.Description  XN 4Jun15 98073 New local stores description
                 strOut = drug.LabelDescription
         plingparse strOut, "!"
         DrugKey = strOut
   End Select

End Function

Private Function FilterIndex(Index() As IndexElement, ByVal FilterValue As String) As Integer
'26Apr02 ATW
'  Description:   Filters the index and returns the number of things left in it.
'
'  Input :        Index()     ;  The array of IndexElement
'                 FilterValue ;  The value to filter stuff on
'
'  Output:        Index()     ;  Returns the array with only the stuff that matches present
'                 Return      ;  The number of things that matched


Dim tmpIndex() As IndexElement
Dim intFilterCount As Integer
Dim intCounter As Integer

   ' copy the index to the temp one
   ReDim tmpIndex(UBound(Index))

   For intCounter = 0 To UBound(Index)
      tmpIndex(intCounter) = Index(intCounter)
   Next intCounter

   ' Filter it.

   For intCounter = 0 To UBound(tmpIndex)
      If Trim$(tmpIndex(intCounter).FilterKey) = Trim$(FilterValue) Then
            Index(intFilterCount) = tmpIndex(intCounter)
            intFilterCount = intFilterCount + 1
         End If
   Next intCounter

   If intFilterCount = 0 Then Exit Function

   ReDim Preserve Index(intFilterCount - 1)
   FilterIndex = intFilterCount

End Function

Private Function GetElementText() As String
'26Apr02 ATW
'  Description  :  Shortcut to routine in XML.bas
'
   GetElementText = XMLGetElementText(m_strXML, m_intXmlPointer)

End Function

Private Function GetReportFilePath() As String
'26Apr02 ATW
'  Description :  Get the path to the desired report file
'
'  Output:     Return      ;  The report file path or empty string
'
Dim intReportCount As Integer
Dim intReportCounter As Integer

Dim intLineChosen As Integer

   intReportCount = HierarchicalReportCount()

   ReDim astrReportPath(1 To intReportCount) As String  '01Jun02 ALL/ATW
   ReDim astrReportSpec(2) As String

   If intReportCount = 0 Then
         popmessagecr "Hierachical report engine", "No hierachical reports defined"
         Exit Function
      End If

   LstBoxFrm.Caption = "Select Report"
   LstBoxFrm.LstBox.Clear

   ReDim astrFile(1 To intReportCount)

   For intReportCounter = 1 To intReportCount
      deflines TxtD$(dispdata$ & "\winord.ini", "HierarchicalReports", "", CStr(intReportCounter), 0), astrReportSpec(), ",", 1, 0
      LstBoxFrm.LstBox.AddItem astrReportSpec(1)
      astrReportPath(intReportCounter) = astrReportSpec(2)
   Next intReportCounter

   LstBoxShow

   intLineChosen = LstBoxFrm.LstBox.ListIndex + 1

   Unload LstBoxFrm

   If intLineChosen > 0 Then
         GetReportFilePath = dispdata$ & "\" & astrReportPath(intLineChosen)
      End If
            
End Function

Private Sub GetReqsToFollow()
'26Apr02 ATW
'  Description :  Fetches all the requisitions "to follow"

On Error GoTo GetReqsToFollow_err

Const REQSPACE_RESERVED = 300
Const REQSPACE_INCREMENT = 150

Dim lngContinue As Long
Dim lngFound As Long
Dim req As orderstruct
Dim strParameters As String
Dim rsToFollows As ADODB.Recordset

   ReDim m_aRequisition(REQSPACE_RESERVED)
   m_intReqCount = 0
   
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("Status", trnDataTypeint, 4, 5) & _
                   gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, "") & _
                   gTransport.CreateInputParameterXML("RequistionNum", trnDataTypeVarChar, 10, "") & _
                   gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                   gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                   gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
   Set rsToFollows = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCriteria", strParameters)
   If Not rsToFollows.EOF Then
      Do While Not rsToFollows.EOF
         ''scanordreqindex 5, "", lngContinue, lngFound
         
         req = FillOrdFromRS(rsToFollows, "WRequis")
         ''getorder req, lngFound, 5, False
         If req.tofollow = "1" And req.status = "5" Then
            If m_intReqCount > UBound(m_aRequisition) Then
               ReDim Preserve m_aRequisition(UBound(m_aRequisition) + REQSPACE_INCREMENT)
            End If
            m_aRequisition(m_intReqCount) = req
            m_intReqCount = m_intReqCount + 1
         End If
         
         rsToFollows.MoveNext
      Loop 'Until lngFound = 0
   End If
   rsToFollows.Close
   Set rsToFollows = Nothing
   ReDim Preserve m_aRequisition(m_intReqCount - 1)
   m_blnReqsLoaded = True

GetReqsToFollow_Cleanup:

Exit Sub

GetReqsToFollow_err:

'Resume GetReqsToFollow_Cleanup
End Sub

Private Sub GetToFollowDrugs()
'26Apr02 ATW
'  Description :  Caches all the drugs that have reqs "to follow"
'
Dim astrDrugCodes() As String

'Dim intDrugCount As Integer
Dim intCounter As Integer
Dim strDrugCode As String

Dim lngFound As Long

'Dim intFoundDrug As Integer  '01Jun02 ALL/ATW

Const DrugSPACE_INIT = 300
Const DrugSPACE_INCREMENT = 150


   ReDim astrDrugCodes(DrugSPACE_INIT)
   m_intDrugCount = 0

   For intCounter = LBound(m_aRequisition) To UBound(m_aRequisition)
      
      If m_intDrugCount > UBound(astrDrugCodes) Then
            ReDim Preserve astrDrugCodes(UBound(astrDrugCodes) + DrugSPACE_INCREMENT)
         End If
      
      strDrugCode = m_aRequisition(intCounter).Code
      If Not IsInArray(astrDrugCodes(), strDrugCode) Then
            astrDrugCodes(m_intDrugCount) = strDrugCode
            m_intDrugCount = m_intDrugCount + 1                   '28Jun02 ATW
         End If

      Next intCounter

   ReDim Preserve astrDrugCodes(m_intDrugCount - 1)               '28Jun02 ATW
   ReDim m_aDrug(m_intDrugCount - 1)                              '28Jun02 ATW

   For intCounter = 0 To m_intDrugCount - 1  ' LBound(astrDrugCodes) To UBound(astrDrugCodes) '28Jun02 ATW
         m_aDrug(intCounter).SisCode = astrDrugCodes(intCounter)
         getdrug m_aDrug(intCounter), 0, 0, False 'intFoundDrug, False '01Jun02 ALL/ATW
      Next intCounter
      
Exit Sub
GetToFollowDrugs_err:


End Sub

Private Sub GetToFollowOrders()
'26Apr02 ATW
'  Description :  Caches all the outstanding orders
'
Dim lngFound As Long
Dim lngContinue As Long

Dim intCounter As Integer
'Dim intOrderCount As Integer                               '28Jun02 ATW ; All instances renamed to m_intOrderCount

Dim Order As orderstruct
Dim strParameters As String
Dim rsOrders As ADODB.Recordset

Const ORDERSPACE_INIT = 300
Const ORDERSPACE_INCREMENT = 150

   ReDim m_aOrder(ORDERSPACE_INIT)
   m_intOrderCount = 0                                      '28Jun02 ATW

   For intCounter = LBound(m_aDrug) To UBound(m_aDrug)
      ''Do
         
         '''''SQL!!! scanordreqindex 1, m_aDrug(intCounter).SisCode, lngContinue, lngFound
         strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "") & _
                      gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, "") & _
                      gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, m_aDrug(intCounter).SisCode) & _
                      gTransport.CreateInputParameterXML("Num", trnDataTypeint, 4, 0) & _
                      gTransport.CreateInputParameterXML("Pickno", trnDataTypeint, 4, 0) & _
                      gTransport.CreateInputParameterXML("StartID", trnDataTypeint, 4, 0) & _
                      gTransport.CreateInputParameterXML("MaxRow", trnDataTypeint, 4, 0)
         Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCriteria", strParameters)

         'If lngFound <> 0 Then
         If Not rsOrders.EOF Then
            Do While Not rsOrders.EOF
            
               If m_intOrderCount > UBound(m_aOrder) Then
                  ReDim Preserve m_aOrder(UBound(m_aOrder) + ORDERSPACE_INCREMENT)
               End If
   
               ''getorder Order, lngFound, 1, False
               Order = FillOrdFromRS(rsOrders, "WOrder")
               
               'If Val(Order.outstanding) > 0 Then
               If (Val(RtrimGetField(rsOrders!outstanding)) > 0) And (Val(RtrimGetField(rsOrders!status)) > 1) Then
                  m_aOrder(m_intOrderCount) = Order         '28Jun02 ATW
                  m_intOrderCount = m_intOrderCount + 1     '28Jun02 ATW
               End If
               
               rsOrders.MoveNext
               
            Loop
         End If
      ''Loop Until lngFound = 0

         lngContinue = 0

      Next intCounter
      
      If m_intOrderCount > 0 Then                               '28Jun02 ATW
            ReDim Preserve m_aOrder(m_intOrderCount - 1)        '28Jun02 ATW
         Else
            ReDim m_aOrder(0)
         End If
         
End Sub

Private Sub GetToFollowSuppliers()
'26Apr02 ATW
'  Description :  Caches all the suppliers to which there are outstanding orders
'
Dim astrSupplierCodes() As String

'Dim intSupplierCount As Integer                                     '28Jun02 ATW
Dim intCounter As Integer
Dim strSupplierCode As String

Dim lngFound As Long

''Dim intFoundSup As Integer
Dim lngFoundSup As Long

Const SupplierSPACE_INIT = 300
Const SupplierSPACE_INCREMENT = 150

   ReDim astrSupplierCodes(SupplierSPACE_INIT)
   m_intSupplierCount = 0                                            '28Jun02 ATW
   
   If m_intOrderCount = 0 Then                                       '28Jun02 ATW
         Exit Sub
      End If

   For intCounter = LBound(m_aOrder) To UBound(m_aOrder)
      
      If m_intSupplierCount > UBound(astrSupplierCodes) Then           '28Jun02 ATW
            ReDim Preserve astrSupplierCodes(UBound(astrSupplierCodes) + SupplierSPACE_INCREMENT)
         End If
      
      strSupplierCode = m_aOrder(intCounter).supcode
      If Not IsInArray(astrSupplierCodes(), strSupplierCode) Then
            astrSupplierCodes(m_intSupplierCount) = strSupplierCode
            m_intSupplierCount = m_intSupplierCount + 1                '28Jun02 ATW
         End If

      Next intCounter

   ReDim Preserve astrSupplierCodes(m_intSupplierCount - 1)
   ReDim m_aSupplier(m_intSupplierCount - 1)

   For intCounter = 0 To m_intSupplierCount - 1 'LBound(astrSupplierCodes) To UBound(astrSupplierCodes) '28Jun02 ATW
         getsupplier astrSupplierCodes(intCounter), 0, lngFoundSup, m_aSupplier(intCounter)
      Next intCounter
      
Exit Sub
GetToFollowSuppliers_err:

End Sub

Private Sub GetToFollowWards()
'26Apr02 ATW
'  Description :  Caches all the wards which have reqs "to follow"
'
Dim astrWardCodes() As String

Dim intCounter As Integer
Dim strWardCode As String

Dim lngFound As Long

''Dim intFoundSup As Integer
Dim lngFoundSup As Long

Const WARDSPACE_INIT = 300
Const WARDSPACE_INCREMENT = 150

On Error GoTo GetToFollowWards_err:

   ReDim astrWardCodes(WARDSPACE_INIT)
   m_intWardcount = 0                                                '28Jun02 ATW

   For intCounter = 0 To m_intReqCount - 1
      
      If m_intWardcount > UBound(astrWardCodes) Then                 '28Jun02 ATW
            ReDim Preserve astrWardCodes(UBound(astrWardCodes) + WARDSPACE_INCREMENT)
         End If
      
      strWardCode = m_aRequisition(intCounter).supcode
      If Not IsInArray(astrWardCodes(), strWardCode) Then
            astrWardCodes(m_intWardcount) = strWardCode
            m_intWardcount = m_intWardcount + 1                       '28Jun02 ATW
         End If

      Next intCounter

   ReDim Preserve astrWardCodes(m_intWardcount - 1)                   '28Jun02 ATW
   ReDim m_aWard(m_intWardcount - 1)                                  '28Jun02 ATW

   For intCounter = 0 To m_intWardcount - 1 'LBound(astrWardCodes) To UBound(astrWardCodes)   '28Jun02 ATW
         getsupplier astrWardCodes(intCounter), 0, lngFoundSup, m_aWard(intCounter)
      Next intCounter
      
Exit Sub
GetToFollowWards_err:

End Sub

Function HierarchicalReportCount() As Integer
'26Apr02 ATW
'  Description : Returns the number of reports set up in WINORD.INI
'
   HierarchicalReportCount = Val(TxtD$(dispdata$ & "\Winord.ini", "HierarchicalReports", "0", "Total", 0))

End Function

Private Function IsInArray(testArray() As String, Value As Variant) As Integer
'26Apr02 ATW
'  Description :  Tests to see if the value is in this array.
'
'  Input :        TestArray()       ;  The array to test
'                 Value             ;  The value to test for
'
'  Output:        Return            ;  Boolean int
'
Dim lngArrayCounter As Long

On Error GoTo IsInArray_err

   For lngArrayCounter = LBound(testArray) To UBound(testArray)
      If testArray(lngArrayCounter) = Value Then
            IsInArray = True
            Exit For
         End If
      Next lngArrayCounter
      
IsInArray_Cleanup:
   
Exit Function
IsInArray_err:
   IsInArray = False
   Resume IsInArray_Cleanup
End Function

Private Sub ItemFillHeap(ByVal ItemType As String, ByVal Index As Integer)
'26Apr02 ATW
'  Description :  Place a particular item on the heap
'
'  Input :        ItemType    ;  The type of item we want
'                 Index       ;  The index of the item in the cache
'
   If m_intReportHeap = 0 Then
         Heap 1, m_intReportHeap, "TO_FOLLOW", "To Follow Heap", 0
      End If

   Select Case ItemType
      Case ITEM_DRUG
         FillHeapDrugInfo m_intReportHeap, m_aDrug(Index), 0
      Case ITEM_SUPPLIER
         FillHeapSupplierInfo m_intReportHeap, m_aSupplier(Index), 0
      Case ITEM_WARD
         FillHeapSupplierInfo m_intReportHeap, m_aWard(Index), 0
      Case ITEM_ORDER
         FillHeapOrdInfo m_intReportHeap, m_aOrder(Index), 0
      Case ITEM_REQUISITION
         FillHeapOrdInfo m_intReportHeap, m_aRequisition(Index), 0
   End Select

End Sub

Private Function ItemGetIndex(ByVal ItemType As String, ByVal SortKey As String, ByVal FilterKey As String, Index() As IndexElement) As Integer
'26Apr02 ATW
'  Description :  Create an index of the specified item
'
'  Input       :  ItemType       ;  The type of item we want to index
'                 SortKey        ;  The sorting key to place in the index
'                 FilterKey      ;  The filter key to place in the index
'
'  Output      :  Index()        ;  The index
'                 Return         ;  The count of things in the index
'
'28Jun02 ATW Improved index bounds by using counts and not ubounds
Dim intSize As Integer
Dim intCounter As Integer
On Error GoTo ItemGetIndex_Err

   Select Case ItemType
      Case ITEM_DRUG
         intSize = m_intDrugCount 'UBound(m_aDrug)             '28Jun02 ATW
      Case ITEM_SUPPLIER
         intSize = m_intSupplierCount 'UBound(m_aSupplier)     '28Jun02 ATW
      Case ITEM_WARD
         intSize = m_intWardcount 'UBound(m_aWard)            '28Jun02 ATW
      Case ITEM_ORDER
         intSize = m_intOrderCount ' UBound(m_aOrder)         '28Jun02 ATW
      Case ITEM_REQUISITION
         intSize = m_intReqCount ' UBound(m_aRequisition)     '28Jun02 ATW
   End Select
   
   ItemGetIndex = intSize
   
   If intSize = 0 Then GoTo ItemGetIndex_Cleanup:

   ReDim Index(intSize - 1)                                    '04Jul02 ATW bound incorrect = resolved duplciate report problem
   
   For intCounter = 0 To intSize - 1
      
      Index(intCounter).id = intCounter

      If SortKey <> "" Then
            Index(intCounter).SortKey = ItemKey(ItemType, intCounter, SortKey)
         End If
      If FilterKey <> "" Then
            Index(intCounter).FilterKey = ItemKey(ItemType, intCounter, FilterKey)
         End If
   Next intCounter

ItemGetIndex_Cleanup:

Exit Function

ItemGetIndex_Err:
   ItemGetIndex = 0
   Resume ItemGetIndex_Cleanup
End Function

Private Function ItemKey(ByVal ItemType As String, ByVal Index As Integer, ByVal KeyName As String) As String
'26Apr02 ATW
'  Description :  Return a particular key for a particular item
'
'  Input       :  ItemType    ;  The type of item
'                 Index       ;  The index of that item in its cache
'                 KeyName     ;  The field we want as a key
'
'  Output      :  Return      ;  The key
'
   Select Case ItemType
      Case ITEM_DRUG
         ItemKey = DrugKey(m_aDrug(Index), KeyName)
      Case ITEM_SUPPLIER
         ItemKey = SupplierKey(m_aSupplier(Index), KeyName)
      Case ITEM_WARD
         ItemKey = SupplierKey(m_aWard(Index), KeyName)
      Case ITEM_ORDER
         ItemKey = OrderKey(m_aOrder(Index), KeyName)
      Case ITEM_REQUISITION
         ItemKey = OrderKey(m_aRequisition(Index), KeyName)
   End Select

End Function

Private Function ItemLink(ByVal ParentType As String, ByVal ChildType As String, key As String) As Integer
'26Apr02 ATW
'  Description :  Return information about how two data types link to each other in the stores schema
'
'  Input       :  ParentType     ;  The parent data
'                 ChildType      ;  The child data
'
'  Output      :  Key            ;  If these two link, this is the key they share
'
'                 Return         ;  0 - No link
'                                   1 - 1-1 Relationship
'                                  >1 - 1-* Relationship
'
Const LINKS = "Ward:1-*:Requisition:*-1:Drug:1-*:Order:*-1:Supplier"   ' Details relationships in the stores data schema
Dim KEYS As String
KEYS = ":" & KEY_SUPPLIER & "::" & KEY_NSVCODE & "::" & KEY_NSVCODE & "::" & KEY_SUPPLIER

ReDim astrLink(8) As String
ReDim astrKey(8) As String

Dim intLinkFrom As Integer
Dim intCounter As Integer

   deflines LINKS, astrLink(), ":(*)", 0, 0
   deflines KEYS, astrKey(), ":(*)", 0, 0
   
   intLinkFrom = -1

   For intCounter = 0 To UBound(astrLink) Step 2
      If ParentType = astrLink(intCounter) Then
            intLinkFrom = intCounter
            Exit For
         End If
   Next intCounter

   If intLinkFrom = -1 Then Exit Function

   If intLinkFrom > 0 Then
         If astrLink(intLinkFrom - 2) = ChildType Then
               ItemLink = IIf(Left$(astrLink(intLinkFrom - 1), 1) = "1", 1, 2)
               key = astrKey(intLinkFrom - 1)
            End If
      End If

   If intLinkFrom < UBound(astrLink) Then
         If astrLink(intLinkFrom + 2) = ChildType Then
               ItemLink = IIf(Right$(astrLink(intLinkFrom + 1), 1) = "1", 1, 2)
               key = astrKey(intLinkFrom + 1)
            End If
      End If

End Function

Private Sub ListElementFromXML(List As ListElement)
'26Apr02 ATW
'  Description :  Sets the state of the passed structure from the XML stream
'
'  Input       :  List     ;  The list to populate
'
Dim isText As Integer
Dim isClose As Integer
Dim isFinished As Integer

   Do
      Select Case NextTag(isText, isClose)
         Case TAG_REPORT
            List.ReportID(List.ReportCount) = NewReportElement()
            ReportElementFromXML m_aReport(List.ReportID(List.ReportCount))
            List.ReportCount = List.ReportCount + 1
         Case TAG_ITEM
            List.Item = GetElementText()
         Case TAG_LINKEDITEM
            If List.LinkedItem = "" Then
                  List.LinkedItem = GetElementText()
               Else
                  List.LinkedItem2 = GetElementText()
               End If
         Case TAG_SPLITTER
            List.Splitter = GetElementText()
         Case TAG_SORTBY
            List.SortBy = GetElementText()
         Case TAG_FILTERBY
            List.FilterBy = GetElementText()
         Case TAG_FORMAT
            List.Format = GetElementText()
         Case TAG_EMPTYLINE
            List.EmptyLine = GetElementText()
         Case TAG_LIST
            If isClose Then isFinished = True
         Case TAG_FOOTER
            List.Footer = GetElementText()
         Case TAG_TITLE
            List.title = GetElementText()
         Case TAG_NAME
            List.name = GetElementText()
         Case Else
            Error 10001
      End Select

   Loop Until isFinished

End Sub

Private Function NewListElement() As Integer
'26Apr02 ATW
'  Description :  Creates a new ListElement in the module-level cache
'
'  Output      :  Return      ;  The index of the new element
'
Const ListSPACE_INIT = 5
Const ListSPACE_INCREMENT = 3

   If m_intListCount = 0 Then
         ReDim m_aList(ListSPACE_INIT)
      End If

   If m_intListCount > UBound(m_aList) Then
         ReDim Preserve m_aList(UBound(m_aList) + ListSPACE_INCREMENT)
      End If

   m_intListCount = m_intListCount + 1

   NewListElement = m_intListCount - 1

End Function

Private Function NewReportElement() As Integer
'26Apr02 ATW
'  Description :  Creates a new ReportElement in the module-level array
'
'  Output      :  Return      ;  The index of the new element
'
' 09May02 ATW Amended to initialize all 6 members of list array

Const REPORTSPACE_INIT = 5
Const REPORTSPACE_INCREMENT = 3
Dim intListCounter As Integer

   If m_intReportCount = 0 Then
         ReDim m_aReport(REPORTSPACE_INIT)
      End If

   If m_intReportCount > UBound(m_aReport) Then
         ReDim Preserve m_aReport(UBound(m_aReport) + REPORTSPACE_INCREMENT)
      End If

   m_intReportCount = m_intReportCount + 1

   For intListCounter = 0 To 5
      m_aReport(m_intReportCount - 1).ListID(intListCounter) = -1
   Next intListCounter

   NewReportElement = m_intReportCount - 1

End Function

Private Function NextTag(isText As Integer, isClose As Integer) As String
'26Apr02 ATW
'  Description :  Shortcut to XML.BAS routine
'
   NextTag = XMLGetNextTag(m_strXML, m_intXmlPointer, isText, isClose)

End Function

Private Function OrderKey(Order As orderstruct, ByVal KeyName As String) As String
'26Apr02 ATW
'  Description :  Return a particular key from an orderstruct
'
'  Input       :  Order       ;  The order struct
'                 KeyName     ;  The desired key
'
'  Output      :  Return      ;  The value of that key
'
   Select Case KeyName
      Case KEY_NSVCODE
         OrderKey = Order.Code
      Case KEY_SUPPLIER
         OrderKey = Order.supcode
   End Select

End Function

Private Sub ReportElementFromXML(Report As ReportElement)
'26Apr02 ATW
'  Description :  Set the state of a ReportElement from the XML stream
'
'  Input/output:  Report      ;  The Report element
'
' 09May02 ATW  Enhancements to support multiple lists per report

Dim isText As Integer
Dim isClose As Integer
Dim isFinished As Integer

   Do
      Select Case NextTag(isText, isClose)
         Case TAG_TITLE
            Report.title = GetElementText()
         Case TAG_LIST
            Report.ListID(Report.ListCount) = NewListElement()
            ListElementFromXML m_aList(Report.ListID(Report.ListCount))
            Report.ListCount = Report.ListCount + 1
         Case TAG_REPORT
            If isClose Then isFinished = True
         Case TAG_FOOTER
            Report.Footer = GetElementText()
         Case Else
            Error 10001
      End Select
   Loop Until isFinished

   Report.CurrentListID = Report.ListID(0)
   
End Sub

Private Sub sortindex(Index() As IndexElement)
'26Apr02 ATW
'  Description :  Sort an index
'
'  Input/Out   :  Index()     ;  This array gets sorted
'
Dim astrIndex() As String
Dim tmpItem As SortElement
Dim intCounter As Integer

   ReDim astrIndex(1 To UBound(Index) + 1)

   For intCounter = 0 To UBound(Index)
      LSet tmpItem = Index(intCounter)
      astrIndex(intCounter + 1) = tmpItem.Item
   Next intCounter

   shellsort astrIndex(), UBound(astrIndex), 3, ""
   
   For intCounter = 0 To UBound(Index)
      tmpItem.Item = astrIndex(intCounter + 1)
      LSet Index(intCounter) = tmpItem
   Next intCounter

End Sub

Private Function SupplierKey(Supplier As supplierstruct, ByVal KeyName As String) As String
'26Apr02 ATW
'  Description :  Return a key field from a supplierstruct
'
'  Input       :  Supplier    ;  The supplier struct
'                 KeyName     ;  The desired key
'
'  Output      :  Return      ;  The key value
'
   Select Case KeyName
      Case KEY_SUPPLIER
         SupplierKey = Supplier.Code
   End Select

End Function

Sub ToFollowReport2()
'26Apr02 ATW
'  Description : Construct and print a hierarchical To-Follow report (#55445)

'06Dec16 TH Replaced RTF(TFS 157969)
'04Jan17 TH Use Local File Parsing (Hosted)

On Error GoTo ToFollowReport2_Err

Dim strReportFile As String
Dim strTemplate As String

Dim strHeader As String
Dim strFooter As String

Dim strFile As String

Dim strReportFilePath As String

   ' determine which report to run

   strReportFilePath = GetReportFilePath()

   If strReportFilePath = "" Then Exit Sub

   ' pre-cache the data
   
   CacheToFollowData

   'GetTextFile strReportFilePath, strTemplate, 0
   GetRTFTextFromDB strReportFilePath, strTemplate, 0  '06Dec16 TH Replaced (TFS 157969)


   SplitFile strTemplate, strHeader, m_strXML, strFooter
   m_intXmlPointer = 0
   
   BuildReportStructure
   
   MakeLocalFile strReportFile
   
   m_intReportFile = FreeFile

   Open strReportFile For Binary Access Write Lock Read Write As m_intReportFile

   WriteOut strHeader

   WriteReport m_aReport(m_intRootReportID), "", ""

   WriteOut strFooter
   
   Close m_intReportFile

   ' Closing footer statistics

   On Error Resume Next
   Heap 10, gPRNheapID, REPORT_ORDERCOUNT, CStr(m_intOrderCount), 0
   Heap 10, gPRNheapID, REPORT_REQCOUNT, CStr(m_intReqCount), 0
   Heap 10, gPRNheapID, REPORT_WARDCOUNT, CStr(m_intWardcount), 0
   Heap 10, gPRNheapID, REPORT_SUPPLIERCOUNT, CStr(m_intSupplierCount), 0
   Heap 10, gPRNheapID, REPORT_DRUGCOUNT, CStr(m_intDrugCount), 0
   On Error GoTo ToFollowReport2_Err:

   'ParseThenPrint "", strReportFile, 1, 0, False '15Jun11 TH Added parameter (F0088129)
   ParseThenPrint "", strReportFile, 1, 0, False, True '04Jan17 TH Use Local File Parsing (Hosted)

ToFollowReport2_Cleanup:
   On Error Resume Next
      Close m_intReportFile
   On Error GoTo 0
Exit Sub
ToFollowReport2_Err:
   popmessagecr "Hierarchical Report Engine", "A problem occured during the report."
   Resume ToFollowReport2_Cleanup
End Sub

Private Sub WriteList(List As ListElement, ByVal ParentType As String, ByVal ParentFilterValue As String)
'26Apr02 ATW
'  Description :  Write a list element to the open file
'
'  Input       :  List                 ;  The list
'                 ParentType           ;  The type of data in the parent report (if there is one)
'                 ParentFilterValue    ;  The value of the filter key in the parent row (if present)
'                 ReportName           ;  The "Name" of the report (used to determine which headers used)
'
Dim intLineCounter As Integer
Dim intReportCounter As Integer

Dim Index() As IndexElement

Dim blnListBroken As Integer

Dim strFilterKey As String

Dim strChildType As String
Dim intChildReport As Integer

   If ParentType <> "" Then
         If ItemLink(ParentType, List.Item, strFilterKey) <> 2 Then
               ' we cant filter this record on it's parent
               ' !!** ERR
               Error 10001
            End If
      Else
         strFilterKey = List.FilterBy
      End If

   ' Check to see that this isn't an empty list
   If ItemGetIndex(List.Item, List.SortBy, strFilterKey, Index()) = 0 Then
         WriteOut List.EmptyLine
         Exit Sub
      End If
      
   ' filter the index if required (and check for empty again)
   If ParentType <> "" Then
         If FilterIndex(Index(), ParentFilterValue) = 0 Then
               WriteOut List.EmptyLine
               Exit Sub
            End If
      End If

   ' sort the index if required
   If List.SortBy <> "" Then
         sortindex Index()
      End If

   WriteOut List.title

   blnListBroken = True
   
   For intLineCounter = 0 To UBound(Index)
      
      If blnListBroken Then
            WriteOut HeaderFromLayout(List.Format, List.name)
            blnListBroken = False
         End If
         
      WriteRow List, Index(intLineCounter).id, (intLineCounter = UBound(Index))

      If List.ReportCount > 0 Then
            
            blnListBroken = True
            
            WriteOut List.Splitter

            For intReportCounter = 0 To List.ReportCount - 1
               intChildReport = List.ReportID(intReportCounter)
               strChildType = m_aList(m_aReport(intChildReport).CurrentListID).Item
               If ItemLink(List.Item, strChildType, strFilterKey) = 2 Then
                     ' this is ok, we can sub-report this
                     WriteReport m_aReport(List.ReportID(intReportCounter)), List.Item, ItemKey(List.Item, Index(intLineCounter).id, strFilterKey)
                  Else
                     ' there is no many-link to this item from here
                     Error 10001
                  End If
            Next intReportCounter
         End If
   Next intLineCounter

   WriteOut List.Footer

End Sub

Private Sub WriteOut(ByVal i_strLine As String)
'26Apr02 ATW
'  Description :  Write i_strLine to the report file
'
   Put m_intReportFile, , i_strLine

End Sub

Private Sub WriteReport(Report As ReportElement, ByVal ParentType As String, ByVal ParentFilterValue As String)
'26Apr02 ATW
'  Description :  Write a report element to the file
'
'  Input       :  Report            ;  The report
'                 ParentType        ;  The type of data in the parent
'                 ParentFilterValue ;  The value of the filter key in the parent
'
' 09May02 ATW  Enhanced to support multiple lists per report

Dim intListCounter As Integer

   WriteOut Report.title

   For intListCounter = 0 To Report.ListCount - 1
      Report.CurrentListID = Report.ListID(intListCounter)
      WriteList m_aList(Report.ListID(intListCounter)), ParentType, ParentFilterValue
      WriteOut Report.Footer
   Next intListCounter

End Sub

Private Sub WriteRow(List As ListElement, ByVal Index As Integer, ByVal isLast As Integer)
'26Apr02 ATW
'  Description :  Write a row from a list
'
'  Input       :  List        ;  The list we are writing from
'                 Index       ;  The index of the entry to write
'                 isLast      ;  Is this the last line in this list?
'
Dim strOut As String
Dim strKey As String
Dim aIndex() As IndexElement
   
   ItemFillHeap List.Item, Index

   If List.LinkedItem <> "" Then
         If ItemLink(List.Item, List.LinkedItem, strKey) = 1 Then
               If ItemGetIndex(List.LinkedItem, "", strKey, aIndex()) > 0 Then
                     If FilterIndex(aIndex(), ItemKey(List.Item, Index, strKey)) = 1 Then
                           ItemFillHeap List.LinkedItem, aIndex(0).id
                        End If
                  Else
                     ' !!** ERR No linked data for this row
                     Error 10001
                  End If
            Else
               ' !!** ERR We can't make this link on a 1-1 basis
               Error 10001
            End If
      End If

   If List.LinkedItem2 <> "" Then
         If ItemLink(List.Item, List.LinkedItem2, strKey) = 1 Then
               If ItemGetIndex(List.LinkedItem2, "", strKey, aIndex()) > 0 Then
                     If FilterIndex(aIndex(), ItemKey(List.Item, Index, strKey)) = 1 Then
                           ItemFillHeap List.LinkedItem2, aIndex(0).id
                        End If
                  Else
                     ' !!** ERR No linked data for this row
                     Error 10001
                  End If
            Else
               ' !!** ERR We can't make this link on a 1-1 basis
               Error 10001
            End If
      End If
   
   strOut = List.Format

   ParseItems m_intReportHeap, strOut, 0

   WriteOut TrimToRTFTable(strOut, False, isLast)

End Sub

