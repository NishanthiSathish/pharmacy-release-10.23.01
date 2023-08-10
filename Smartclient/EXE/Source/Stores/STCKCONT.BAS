Attribute VB_Name = "Module9"
'11Dec91 CKJ Structure moved here from individual progs,
'            stklevl inc from 2 to 3 chars
'            paksize inc from 3 to 4 chars
'08Jun92 ASC added last issue for screen reminder of issue
'31Dec93 CKJ Added lastinvincVAT!
'25Jan94 CKJ Added FullPageCS & the pseudo NSVs
' 9Feb94 CKJ Added AskBatchNum
'21Feb94 CKJ Added Delrequis
'22Apr95 ASC OrdPrintprice$ added
' 4May95 CKJ Added OrdPrintLin, OrdPrintprice$ changed to OrdPrintprice%
'30Dec97 EAC Allow Ward requisitions to be printed as "8x100" instead of "800"
'25Feb98 EAC Stock Transfer mods
'02Mar98 EAC Configurable setting for FindrDrug in Ward stock lists
'08May98 CKJ Noted several vars are variants - no defint a-z, and no type dec char
'11Aug98 TH  Added NSVReconciliation$ to handle invoice total reconciliations
'26Jan99 TH  Added dailyissue
'01Apr04 CKJ {SP1}
'09Apr10 XN  F0068649 EDI orders have seprate max number of lines per an order
'14Apr10 TH  Ported ReconcilThreshold stuff (F0056463) 31Aug05 PJC Added

DefInt A-Z                       '08May98 CKJ added
Option Explicit                  '08May98 CKJ added

Type drugdetails
   drugttl As String * 56        ' V4.21 (was 35)
   stklevl As String * 9         '10Sep96 EAC make same as drugparameters
   paksize As String * 5         '10Sep96 EAC make same as drugparameters
   prepack As String * 1
   catno As String * 7
   lastissue As String * 5
   lastissuedate As String * 10
   localcode As String * 7
   posn As Long
   dailyissue As String * 5  '26Jan99 TH
   barcode As String * 15
   LayoutID As Long      'SQL added to directly key record back to DB
End Type

'08May98 CKJ Noted several vars are variants - no defint a-z, and no type dec char
'Global ownname$, sup As supplierstruct, lastinvtotal!, invoicenum$, overdue$, ordmessage$, ordcontact$, tp$, picknumoflines, delreceipt, delreconcile, preprint$, maxnumoflines%, lastinvincVAT!, FullPageCS, NSVcarriage$, NSVdiscount$, AskBatchNum%, Delrequis%, OrdPrintPrice%, OrdPrintLin%, ProgressBarScale%, ordnumprefix$, owname$, PrintStockCost%
Global ownname$, sup As supplierstruct, invoicenum$, overdue$, ordmessage$
Global ordcontact$, tp$, picknumoflines%, delreceipt%, delreconcile%, preprint$, maxnumoflines%, edimaxnumoflines%  'XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
Global FullPageCS%, NSVcarriage$, NSVdiscount$, AskBatchNum%, Delrequis%
Global OrdPrintPrice%, OrdPrintLin%, ProgressBarScale%, ordnumprefix$, PrintStockCost%
'Global lastinvincVAT!, owname$, lastinvtotal!   {SP1}

Global PrintCanceledOrder$
Global PrintInPacks%                '30Dec97 EAC
Global AdjCostCentre As String * 5  '25Feb98 EAC added for use with Stock Transfers
Global WSStores%                    '02Mar98 EAC Added
Global NSVReconciliation$           '11Aug98 TH  Added
Global ReconcilThresholdVal$        '14Apr10 TH Ported (F0056463) 31Aug05 PJC Added


' returns the maximum number of lines allowed for a file
' Depends on the supplier type
' EDI Method use WConfiguration value edimaxnumoflines
' All other methods use WConfiguration value maxnumoflines
' XN 09Apr10 F0068649 EDI orders have seprate max number of lines per an order
Function GetMaxNoOfLinesForOrder(ByVal supplierMethod As String) As Integer
    If supplierMethod = "E" Then
        GetMaxNoOfLinesForOrder = edimaxnumoflines
    Else
        GetMaxNoOfLinesForOrder = maxnumoflines
    End If
End Function

