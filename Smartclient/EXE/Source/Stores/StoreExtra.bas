Attribute VB_Name = "StoreExtra"
'  StoreExtra
'  ----------
'06Jul11 CKJ Added defbool
'20Aug12 TH  UpdatePanels: PSO support for configurable panels -main data (TFS 41427)
'27Feb13 TH  ConstructInfoDisplay: Added new support for PSO specific panels (TFS 57435)
'24Apr13 XN  Main: Changed connection string encryption seed to work on any PC (60910)

Option Explicit
DefBool A-Z

Private Sub ConstructInfoDisplay(strPathfile As String, strSection As String, ctlDisplay As Control, ByVal intStatus As Integer)
'31Jan03 TH (PBSv4) Written / merged
'31Jan03 TH (PBSv4) MERGED
'27Feb13 TH Added new support for PSO specific panels (TFS 57435)

Dim intFound As Integer, strTmp As String, intCount As Integer, intEntry As Integer, ReadOnly%, intDummy
Dim intCharCount As Integer, strValue As String
Dim intOK As Integer, strSql As String
Dim strPBSAuthNum As String, strPBSOrigNum As String
Dim intmaxline As Integer
Dim intNumOfEntries As Integer
Dim intRows As Integer
Const rowheight = 260

   ctlDisplay.Height = rowheight
   If ctlDisplay.Width < 10000 Then
      intmaxline = 112 '73 '112
   Else
      intmaxline = 148
   End If

   ReDim strItems(2) As String
   
   If g_blnPSO Then intNumOfEntries = Val(TxtD(strPathfile, strSection & Format$(intStatus) & "PSO", "", "Lines", intFound)) '27Feb13 TH Added new support for PSO specific panels (TFS 57435)
   
   If intNumOfEntries = 0 Then '27Feb13 TH
      intNumOfEntries = Val(TxtD(strPathfile, strSection & Format$(intStatus), "", "Lines", intFound))
      If intNumOfEntries = 0 Then
         intNumOfEntries = Val(TxtD(strPathfile, strSection, "", "Lines", intFound))
      Else
         strSection = strSection & Format$(intStatus)
      End If
   Else                                                        '27Feb13 TH
      strSection = strSection & Format$(intStatus) & "PSO"     '    "
   End If                                                      '    "
   
   If intNumOfEntries = 0 Then ctlDisplay.Visible = False: Exit Sub
   
   ctlDisplay.AutoRedraw = True
   ctlDisplay.tabstop = False
   ctlDisplay.Cls
   ctlDisplay.Visible = True
   
   For intCount = 1 To intNumOfEntries
      strTmp = TxtD(strPathfile, strSection, "", Format$(intCount), intFound)
      ReDim strItems(2)
      deflines strTmp, strItems(), "|", 0, (intDummy)
      If Trim$(strItems(1)) <> "" Then
         If LCase$(Trim$(strItems(0))) = "crlf" Then
            ctlDisplay.Height = ctlDisplay.Height + rowheight
            ctlDisplay.Print
         Else
            Heap 11, gPRNheapID, strItems(1), strValue, 0
            If strValue = "" Then strValue = TxtD(strPathfile, strSection, "Blank", "DefaultScreenValue", 0)
            intCharCount = intCharCount + Len(strItems(0)) + Len(strValue) + 5
            If intCharCount > intmaxline Then
               ctlDisplay.Height = ctlDisplay.Height + rowheight
               ctlDisplay.Print
               ctlDisplay.FontBold = False
               ctlDisplay.Print strItems(0) & " : ";
               ctlDisplay.FontBold = True
               If UBound(strItems) = 2 Then
                  If strItems(2) = "crlf" Then
                     ctlDisplay.Print strValue;
                     intCharCount = 150
                  Else
                     ctlDisplay.Print strValue & "  ";
                     intCharCount = Len(strItems(0)) + Len(strValue) + 5
                  End If
               Else
                  ctlDisplay.Print strValue & "  ";
                  intCharCount = Len(strItems(0)) + Len(strValue) + 5
               End If
               
            Else
               ctlDisplay.FontBold = False
               ctlDisplay.Print strItems(0) & " : ";
               ctlDisplay.FontBold = True
               intCharCount = intCharCount + Len(strItems(0)) + Len(strValue) + 5
               If UBound(strItems) = 2 Then
                  If strItems(2) = "crlf" Then
                     ctlDisplay.Print strValue; '& Space$(150);
                     'ctlDisplay.Print
                     intCharCount = 150
                  Else
                     ctlDisplay.Print strValue & "  ";
                  End If
               Else
                  ctlDisplay.Print strValue & "  ";
               End If
            End If
         End If
      End If
   Next
   intRows = Val(terminal("StoresPanelsRows", "0"))
   If intRows > 0 Then
      ctlDisplay.Height = intRows * rowheight
   End If
   ReDim strLines(0)

End Sub

Public Sub UpdatePanels(ByRef ord As orderstruct, ByVal intStatus As Integer)
'20Aug12 TH PSO support for configurable panels (TFS 41427)

Dim udt_drug As DrugParameters
Dim udt_Sup As supplierstruct
Dim strStatus As String
Dim strTotalOrderValue As String
Dim strMinOrderValue As String

   If TrueFalse(terminal("DisplayStoresPanels", "Y")) Then
      clearsup udt_Sup                                      '06Jul11 CKJ added
      If ord.supcode <> "" Then
         getsupplier ord.supcode, 0, 0, udt_Sup
      End If
      FillHeapSupplierInfo gPRNheapID, udt_Sup, 0
      Heap 10, gPRNheapID, "TotOrdValMinOrdVal", "", 0      '06Jul11 CKJ added
      Heap 10, gPRNheapID, "TotalOrderValue", "", 0 '01Jul12 TH
      
      If intStatus = 1 And ord.supcode <> "" And TrueFalse(terminal("DisplayStoresPanelsMinOrderValue", "N")) Then        '22May05 TH Added '31Jul12 TH Added further check on supcode and setting
         strTotalOrderValue = CalculateWOrderValue(ord.supcode)         '01Jul12 TH Added
         Heap 10, gPRNheapID, "TotalOrderValue", strTotalOrderValue, 0  '01Jul12 TH Added
         'Heap 11, gPRNheapID, "TotalOrderValue", strTotalOrderValue, 0
         Heap 11, gPRNheapID, "sMinOrderValue", strMinOrderValue, 0
         Heap 10, gPRNheapID, "TotOrdValMinOrdVal", strTotalOrderValue & "/" & strMinOrderValue, 0
      End If
      FillHeapPSOrderInfo gPRNheapID, ord.OrderID, intStatus, 0  '20Aug12 TH PSO support for configurable panels (TFS 41427)
      FillHeapOrdInfo gPRNheapID, ord, 0
      If ord.Code <> "" Then
         udt_drug.SisCode = ord.Code
         getdrug udt_drug, 0, 0, 0
         FillHeapDrugInfo gPRNheapID, udt_drug, 0
      End If
      ConstructInfoDisplay dispdata$ & "\OrdPanel.ini", "ProductInfo", MainScreen.PicInfo1, intStatus
      ConstructInfoDisplay dispdata$ & "\OrdPanel.ini", "SupplierInfo", MainScreen.PicInfo2, intStatus
   End If

End Sub

Sub Main()
'   frmBlank.Tag = Format$(((1# * frmBlank.Top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)   '11Aug08 CKJ
   frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC
   
   StoresMain
End Sub

Public Function PyxisSetup(blnStub As Boolean) As Boolean
'10May05 TH Stubbage
   PyxisSetup = False
End Function

Public Function OnPyxisWard(strStub As String) As Boolean
'10May05 TH Stubbage
   OnPyxisWard = False
End Function

Sub CreatePyxisEvent(int2 As Integer, int1 As Integer, strsub3 As String, strsub2 As String, sng1 As Single, strsub1 As String)
'10May05 TH Stub
End Sub

Function GetNewParentHWnd() As Long
'10Feb07 CKJ Needed by IPlink to set the parent of the topmost form
'            Since MainScreen is called non modally from sub Main, it appears not to be
'            recognised as the ultimate parent by SetWindowWord() API
'06Mar07 CKJ Changed Int to Long and moved to StoreExtra

   On Error Resume Next
   GetNewParentHWnd = MainScreen.Hwnd
   On Error GoTo 0

End Function

Public Sub CreatePSOrder(a As Long)
'Stubbage
End Sub

Public Function GetPSOSupplierText() As String
'Stubbage
End Function
Function getTotalRepeats() As Integer
'Stubbage
getTotalRepeats = 0
End Function
