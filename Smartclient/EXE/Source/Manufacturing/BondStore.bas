Attribute VB_Name = "BondStore"
'26Jun13 TH Written
'Intended as code to support Pharmacy Bond Store (TFS 56621)
'22Sep15 TH  BondStoreReleaseBatch: Bond store cost centre should be used not the main MANU code (TFS 127582)
'10Feb16 TH  BondStoreReleaseBatch: Fixed cut and paste error - option says release not destroy batch (TFS 144417)
'17Feb16 TH  BondStoreReleaseBatch: Changed error msg also after Code Review (TFS 144417)

Option Explicit
DefInt A-Z

Dim BondID() As Long
Dim m_strFilter As String

Sub AddToBondStore(ByVal strNSVCode As String, ByVal strDescription As String, ByVal strbatchexpiry As String, ByVal sglQty As Single, ByVal strBatchNumber As String, ByVal totalCost As Single, ByVal totalcostExVAT As Single, ByVal sglQAQty As Single)
'26Jun13 TH Written to store records in the Bond Store table (TFS 56621)
Dim strParams As String
Dim lngResult As Long
Dim dteExpiry As Date

   dteExpiry = CDate(strbatchexpiry)
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
               gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, strDescription) & _
               gTransport.CreateInputParameterXML("Batchnumber", trnDataTypeVarChar, 25, strBatchNumber) & _
               gTransport.CreateInputParameterXML("Expiry", trnDataTypeDateTime, 8, dteExpiry) & _
               gTransport.CreateInputParameterXML("Issue_To_Bond", trnDataTypeDateTime, 8, Now) & _
               gTransport.CreateInputParameterXML("qty", trnDataTypeFloat, 8, sglQty) & _
               gTransport.CreateInputParameterXML("TotalCostExVat", trnDataTypeFloat, 8, totalcostExVAT) & _
               gTransport.CreateInputParameterXML("TotalCostVat", trnDataTypeFloat, 8, (totalCost - totalcostExVAT)) & _
               gTransport.CreateInputParameterXML("TotalCostIncVat", trnDataTypeFloat, 8, totalCost) & _
               gTransport.CreateInputParameterXML("qty", trnDataTypeFloat, 8, sglQAQty)
               
   lngResult = gTransport.ExecuteInsertSP(g_SessionID, "PharmacyBondStore", strParams)
   

End Sub

Sub LoadBondStore()

Dim frmBond As FrmBondStore
Dim loopvar As Integer
Dim tblwidth As Integer
Dim numofcols As Integer
Dim found As Integer
Dim numofsegs As Integer
Dim colwidth As Integer         '31Mar04 CKJ added type declaration
Dim colformat As Integer
Dim displaytxtbox As Integer
Dim displaygauge As Integer
Dim displaylist As Integer
Dim hdrline As String, widthline As String, lineformat As String, columntypeline As String
Dim heading As String
Dim prompt As String
Dim gridtxt As String
Dim lbltext As String
Dim lngpanleWidth As Long
Dim intExtraWidth As Integer
Dim sglColModifier As Single
Dim StrSectionHdr As String
Dim rsBond As ADODB.Recordset
Dim strParams As String

   Set frmBond = New FrmBondStore

   numofcols = Val(TxtD$(dispdata$ + "\BondStore.ini", "BondStore", "", "noofcols", found))
   
      'resize array to be correct size
      If numofcols > 0 Then
         ReDim colheadings(1 To numofcols) As String
         ReDim OColumnType(1 To numofcols) As String
      Else
         ReDim colheadings(1) As String
         ReDim OColumnType(1) As String
      End If
      
      sglColModifier = 1
      frmBond.lvwBond.ListItems.Clear

      'set column headings and widths for each column
      frmBond.lvwBond.View = lvwReport
      frmBond.lvwBond.ListItems.Clear
      frmBond.lvwBond.ColumnHeaders.Clear
      tblwidth = 0
      
      If numofcols > 0 Then
         For loopvar = 1 To numofcols
            hdrline$ = "heading" + Trim$(Str$(loopvar))
            widthline$ = "width" + Trim$(Str$(loopvar))
            lineformat$ = "format" + Trim$(Str$(loopvar))
            columntypeline$ = "type" + Trim$(Str$(loopvar))
            heading$ = TxtD$(dispdata$ + "\BondStore.ini", "BondStore", "", hdrline$, found)
            'SQL MainScreen.lvwMainScreen.ColumnName(loopvar) = heading$
            colwidth = Val(TxtD$(dispdata$ + "\BondStore.ini", "BondStore", "", widthline$, found))
            colwidth = colwidth * sglColModifier
            'SQL MainScreen.lvwMainScreen.ColumnWidth(loopvar) = colwidth
            colformat = Val(TxtD$(dispdata$ + "\BondStore.ini", "BondStore", "", lineformat$, found))
''                  If colformat = 0 Then
''                        'SQL MainScreen.lvwMainScreen.ColumnStyle(loopvar) = 1
''                     Else
''                        'SQL MainScreen.lvwMainScreen.ColumnStyle(loopvar) = colformat
''                     End If
            tblwidth = tblwidth + (colwidth * 80)
            OColumnType(loopvar) = LCase$(TxtD$(dispdata$ + "\BondStore.ini", "BondStore", "text", columntypeline$, found))   '06Jul11 CKJ added lcase()
            frmBond.lvwBond.ColumnHeaders.Add , "H:" & Format$(loopvar), heading$, (colwidth * 80)
            If loopvar > 1 And OColumnType(loopvar) <> "text" Then                           '06Jul11 CKJ added ////
               frmBond.lvwBond.ColumnHeaders(loopvar).Alignment = lvwColumnRight    '   "
            End If
         Next
         frmBond.lvwBond.GridLines = True
         'MainScreen.lvwMainScreen.ColumnHeaders.item.Alignment = lvwColumnCenter
         '&H80000002&
         'Move the TrueGrid to the Centre of the Picture Box
         'frmBond.lvwMainScreen.Top = (MainScreen.PicLayout.ScaleHeight / 2) - (MainScreen.lvwMainScreen.Height / 2)
         'MainScreen.lvwMainScreen.top = (MainScreen.PicLayout.ScaleHeight / 1.5) - (MainScreen.lvwMainScreen.Height / 1.5)
         'frmBond.lvwMainScreen.Left = (MainScreen.PicLayout.ScaleWidth / 2) + (MainScreen.lvwMainScreen.Width / 2)
      End If
      
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)

      Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebySiteID", strParams)

      
      fillBondTable frmBond, 0, rsBond
      
      frmBond.lblTitle.Caption = "Pharmacy Bond Store : Showing All items"
            
      frmBond.Show 1
      
End Sub

Sub fillBondTable(frm As Form, ByVal intMode As Integer, ByRef rsBond As ADODB.Recordset)


Dim intloop As Integer
Dim lngPtr As Long
Dim found&
Dim strValue As String
Dim strKey As String
Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem

   frm.lvwBond.ListItems.Clear

   ReDim BondID(0)
   
   intloop = 0
   If rsBond.RecordCount > 0 Then
      rsBond.MoveFirst
      ReDim BondID(rsBond.RecordCount)
      Do While Not rsBond.EOF

         intloop = intloop + 1
         strKey = "R" & CStr(intloop)
         Set lvwItem = frm.lvwBond.ListItems.Add(, strKey & ":C1", RtrimGetField(rsBond!batchnumber))
         lvwItem.ListSubItems.Add , strKey & ":C2", Format(RtrimGetField(rsBond!Issue_To_Bond), "dd/mmm/yyyy")
         lvwItem.ListSubItems.Add , strKey & ":C3", RtrimGetField(rsBond!NSVCode)
         lvwItem.ListSubItems.Add , strKey & ":C4", RtrimGetField(rsBond!Description)
         lvwItem.ListSubItems.Add , strKey & ":C5", RtrimGetField(rsBond!Qty)
         lvwItem.ListSubItems.Add , strKey & ":C6", RtrimGetField(rsBond!QAQty)
         lvwItem.ListSubItems.Add , strKey & ":C7", Format(RtrimGetField(rsBond!expiry), "dd/mmm/yyyy")
         
         BondID(intloop) = rsBond!PharmacyBondStoreID
            
         rsBond.MoveNext
      Loop
      
      frm.PicInfo1.Left = frm.lvwBond.Left
      frm.PicInfo1.Top = (frm.lvwBond.Top + frm.lvwBond.Height + 300)
      frm.PicInfo1.Height = 400
      frm.PicInfo1.Visible = False
      
      frm.lvwBond.Refresh
      
      If frm.lvwBond.ListItems.count > 0 Then
         frm.lvwBond.ListItems(1).Selected = True
         UpdateBondPanel frm
      End If
      
      rsBond.Close
      Set rsBond = Nothing
   Else
      frm.PicInfo1.Visible = False '24Sep13 TH panel is invisible
   End If
End Sub
Sub UpdateBondPanel(ByRef frmBond As Form)
'20Aug12 TH PSO support for configurable panels (TFS 41427)

Dim udt_drug As DrugParameters
Dim lngPharmacyBondStoreID As Long
Dim strParams As String
Dim rsBond As ADODB.Recordset

   If TrueFalse(terminal("DisplayBondPanel", "Y")) Then
   
      lngPharmacyBondStoreID = BondID(frmBond.lvwBond.SelectedItem.Index)
      'Get NSV and Costs and add to heap
      
      strParams = gTransport.CreateInputParameterXML("PharmacyBondStoreID", trnDataTypeint, 4, lngPharmacyBondStoreID)
      
      Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyPharmacyBondStoreID", strParams)
      
      If Not rsBond.EOF Then
         rsBond.MoveFirst
         'Costs to print heap
         
         udt_drug.SisCode = RtrimGetField(rsBond!NSVCode)
         
         getdrug udt_drug, 0, 0, False
         FillHeapDrugInfo gPRNheapID, udt_drug, 0
         'Get Costs too
        
         Heap 10, gPRNheapID, "bondcost/100", Format$(RtrimGetField(rsBond!TotalCostIncTax) / 100, "0.00"), 0
         Heap 10, gPRNheapID, "bondcostnet/100", Format$(RtrimGetField(rsBond!totalcostExTax) / 100, "0.00"), 0
         Heap 10, gPRNheapID, "bondcosttax/100", Format$(RtrimGetField(rsBond!totalcosttax) / 100, "0.00"), 0
         'Other Bond stuff
         Heap 10, gPRNheapID, "bondBatchnum", RtrimGetField(rsBond!batchnumber), 0
         Heap 10, gPRNheapID, "bondQAQty", RtrimGetField(rsBond!QAQty), 0
         Heap 10, gPRNheapID, "bondqty", RtrimGetField(rsBond!Qty), 0
         Heap 10, gPRNheapID, "bondissuedate", Format$(RtrimGetField(rsBond!Issue_To_Bond), "dd/mm/yyyy"), 0
         Heap 10, gPRNheapID, "bondissuetime", Format$(RtrimGetField(rsBond!Issue_To_Bond), "hh:nn"), 0
         Heap 10, gPRNheapID, "bondexpirydate", Format$(RtrimGetField(rsBond!expiry), "dd/mm/yyyy"), 0
         Heap 10, gPRNheapID, "bondexpirytime", Format$(RtrimGetField(rsBond!expiry), "hh:nn"), 0
         Heap 10, gPRNheapID, "bonddescription", RtrimGetField(rsBond!Description), 0
      End If
      rsBond.Close
      Set rsBond = Nothing
      
      ConstructInfoDisplay dispdata$ & "\BondPanel.ini", "BondInfo", frmBond.PicInfo1, 0
      
   End If

End Sub
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
      intmaxline = 200 '73 '112
   Else
      intmaxline = 250
   End If

   ReDim strItems(2) As String
   
   
   intNumOfEntries = Val(TxtD(strPathfile, strSection, "", "Lines", intFound))
                                                           '    "
   
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

Sub BondStoreDestroyBatch(ByVal frmBond As Form, ByVal lngIndex As Long)

Dim lngPharmacyBondStoreID As Long
Dim strAns As String
Dim strBatchNumber As String
Dim strExpiry As String
Dim strIssuedtoBond As String
Dim lngOK As Long
Dim strWard As String
Dim lngFound As Long
Dim strParams As String
Dim rsBond As ADODB.Recordset
Dim StrBatch As String
Dim totalCost!
Dim totalcostExVAT!


   strAns = "Y"
   
   
   lngPharmacyBondStoreID = BondID(lngIndex)
   
   'Get details from the DB
   strParams = gTransport.CreateInputParameterXML("PharmacyBondStoreID", trnDataTypeint, 4, lngPharmacyBondStoreID)
      
   Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyPharmacyBondStoreID", strParams)
   
   If Not rsBond.EOF Then
      rsBond.MoveFirst
      StrBatch = RtrimGetField(rsBond!batchnumber)
      strExpiry = Format$(RtrimGetField(rsBond!expiry), "DD/MM/YYYY")
      strIssuedtoBond = Format$(RtrimGetField(rsBond!Issue_To_Bond), "DD/MM/YYYY")
      Qty! = GetField(rsBond!Qty)
      totalCost! = GetField(rsBond!TotalCostIncTax)
      totalcostExVAT! = GetField(rsBond!totalcostExTax)
   End If
   
   rsBond.Close
   Set rsBond = Nothing
   If Trim$(StrBatch) <> "" Then
      Confirm "?Destroy Batch ", " Destroy Batch : " & StrBatch & " (Expires on : " & strExpiry & " Issued to Bond Store on " & strIssuedtoBond & ")" & crlf & crlf & "Are you sure you wish to destroy this batch ?", strAns, k
      If strAns = "Y" Then
         'Collect any notes for this
         k.Max = 200
         strAns = ""
         inputwin "Bond Store - ", "Destroy Batch : " & StrBatch & " Expires on : " & strExpiry & " Issued to Bond Store on " & strIssuedtoBond & crlf & "Enter any notes required for audit", strAns, k
         'If Not k.esd Then
         strParams = gTransport.CreateInputParameterXML("PharmacyBondStoreID", trnDataTypeint, 4, lngPharmacyBondStoreID) & _
                     gTransport.CreateInputParameterXML("UserID", trnDataTypeVarChar, 4, UserID$) & _
                     gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                     gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Now) & _
                     gTransport.CreateInputParameterXML("Note", trnDataTypeVarChar, 200, Trim$(strAns)) & _
                     gTransport.CreateInputParameterXML("Release", trnDataTypeBit, 1, 0)
         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyBondStoreArchive", strParams)
         
         If lngOK > 0 Then
            'Now update the grid
            If Trim$(m_strFilter) <> "" Then
               strParams = m_strFilter
               Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyCriteria", strParams)
            Else
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
               Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebySiteID", strParams)
            End If
            fillBondTable frmBond, 0, rsBond
         Else
            popmessagecr "", ""
         End If
   
         'End If
         
      End If
   Else
      popmessagecr "!BondStore", "The selected batch cannot be found in the Bond Store and cannot be destroyed"
   End If
   
   
End Sub
Sub BondStoreReleaseBatch(ByVal frmBond As Form, ByVal lngIndex As Long)
'21Aug13 TH  (TFS 71664) MBBR now not supported handled as MB
'22Sep15 TH  Bond store cost centre should be used not the main MANU code (TFS 127582)
'10Feb16 TH  Fixed cut and paste error - option says release not destroy batch (TFS 144417)
'17Feb16 TH  Changed error msg also after Code Review (TFS 144417)

Dim lngPharmacyBondStoreID As Long
Dim strAns As String
Dim strBatchNumber As String
Dim strExpiry As String
Dim strIssuedtoBond As String
Dim lngOK As Long
Dim strWard As String
Dim intFound As Integer
Dim strNSVCode As String
Dim oldstklvl!
Dim strParams As String
Dim rsBond As ADODB.Recordset
Dim StrBatch As String
Dim totalCost!
Dim totalcostExVAT!
Dim DrugNum As Long

   strAns = "Y"
   
   lngPharmacyBondStoreID = BondID(lngIndex)
   
   'Get details from the DB
   strParams = gTransport.CreateInputParameterXML("PharmacyBondStoreID", trnDataTypeint, 4, lngPharmacyBondStoreID)
      
   Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyPharmacyBondStoreID", strParams)
   
   If Not rsBond.EOF Then
      rsBond.MoveFirst
      StrBatch = RtrimGetField(rsBond!batchnumber)
      strExpiry = Format$(RtrimGetField(rsBond!expiry), "DD/MM/YYYY")
      strIssuedtoBond = Format$(RtrimGetField(rsBond!Issue_To_Bond), "DD/MM/YYYY")
      Qty! = GetField(rsBond!Qty)
      totalCost! = GetField(rsBond!TotalCostIncTax)
      totalcostExVAT! = GetField(rsBond!totalcostExTax)
      strNSVCode = RtrimGetField(rsBond!NSVCode)
   End If
   
   rsBond.Close
   Set rsBond = Nothing
   If Trim$(StrBatch) <> "" Then
      'Confirm "?Destroy Batch ", " Release Batch : " & StrBatch & " (Expires on : " & strExpiry & " Issued to Bond Store on " & strIssuedtoBond & ")" & crlf & crlf & "Are you sure you wish to release this batch ?", strAns, k
      Confirm "?Release Batch ", " Release Batch : " & StrBatch & " (Expires on : " & strExpiry & " Issued to Bond Store on " & strIssuedtoBond & ")" & crlf & crlf & "Are you sure you wish to release this batch ?", strAns, k '10Feb16 TH Fixed cut and paste error (TFS 144417)
      If strAns = "Y" Then
         'Collect any notes for this
         k.Max = 200
         strAns = ""
         'k.decimals = True                                                    '        "
         inputwin "Bond Store - ", "Release Batch : " & StrBatch & " Expires on : " & strExpiry & " Issued to Bond Store on " & strIssuedtoBond & crlf & "Enter any notes required for audit", strAns, k
         'If Not k.esd Then
         strParams = gTransport.CreateInputParameterXML("PharmacyBondStoreID", trnDataTypeint, 4, lngPharmacyBondStoreID) & _
                     gTransport.CreateInputParameterXML("UserID", trnDataTypeVarChar, 4, UserID$) & _
                     gTransport.CreateInputParameterXML("Terminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                     gTransport.CreateInputParameterXML("Date", trnDataTypeDateTime, 8, Now) & _
                     gTransport.CreateInputParameterXML("Note", trnDataTypeVarChar, 200, Trim$(strAns)) & _
                     gTransport.CreateInputParameterXML("Release", trnDataTypeBit, 1, 1)
         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyBondStoreArchive", strParams)
         
         If lngOK > 0 Then
           'Now we need to book the stock in and add the value
            'strWard = UCase$(TxtD(dispdata$ & "\patmed.ini", "Manufacturing", "MANU", "CostCentre", intFound))
            strWard = UCase$(TxtD(dispdata$ & "\patmed.ini", "manufacturing", "BOND", "BONDCostCentre", intFound))  '22Sep15 TH Replaced above as the Bond store cost centre should be used not the main MANU code (TFS 127582)
            'If Not intFound Or strWard = "" Then popmessagecr "Patmed.ini entry missing", "No 'CostCentre =' under [manufacturing] using MANU as default - contact system manager"    '
            If strWard = "" Then strWard = "MANU"                                                                                                                                    '19Jun98 CFY Added
   
            d.SisCode = strNSVCode
            getdrug d, DrugNum, 0, False
            
            setm_sgnCivasDose Qty!
            gCIVASdos$ = Format$(Qty!)
            setbatchnum StrBatch
            
            'Translog d, DrugNum, UserID$, "", dp!((Qty!) * -1), StrBatch, strWard, "", "M", SiteNumber, "MBBR", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)   'Book into Manu
            Translog d, DrugNum, UserID$, "", dp!((Qty!) * -1), StrBatch, strWard, "", "M", SiteNumber, "MB", Str$(totalCost! * -1) & Chr$(160) & Str$(totalcostExVAT! * -1)   '21Aug13 TH  (TFS 71664)MBBR now not supported handled as MB
            
            AddStockOfBatch d.SisCode, strExpiry, dp!((Qty!) / Val(d.convfact)), StrBatch                                                                                                                                                                                                                       '05Aug99 CFY
            getdrug d, DrugNum, 0, True   '<--------- LOCK drug record 'Update stocklevel and cost for manufactured item                                                                                                      '05Aug99 CFY
            oldstklvl! = Val(d.stocklvl)                                                                                                                                                                        '05Aug99 CFY
            d.stocklvl = LTrim$(Str$(dp!(Val(d.stocklvl) + Qty!)))                                                                                                                                              '05Aug99 CFY
                                                                                                                                                      '05Aug99 CFY
            If Val(d.stocklvl) <> 0 Then
               d.cost = Format$((Val(d.cost) * oldstklvl! / Val(d.convfact) + totalcostExVAT!) / (Val(d.stocklvl) / Val(d.convfact)))
            Else
               If (Qty!) <> 0 Then d.cost = Format$((totalcostExVAT!) / ((Qty!) / Val(d.convfact)))
            End If
            putdrug d
            
            setm_sgnCivasDose 0
            setbatchnum ""
            gCIVASdos$ = ""
            
            'Now update the grid
            If Trim$(m_strFilter) <> "" Then
               strParams = m_strFilter
               Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebyCriteria", strParams)
            Else
               strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
               Set rsBond = gTransport.ExecuteSelectSP(g_SessionID, "pPharmacyBondStorebySiteID", strParams)
            End If
            fillBondTable frmBond, 0, rsBond
            
         Else
            
         End If
   
         'End If
         
      End If
   Else
      'popmessagecr "!BondStore", "The selected batch cannot be found in the Bond Store and cannot be destroyed"
      popmessagecr "!BondStore", "The selected batch cannot be found in the Bond Store and cannot be released"  '17Feb16 TH Changed on Code Review (TFS 144417)
   End If
   
   
End Sub
Sub setBondFilter(ByVal strFilter As String)

   m_strFilter = strFilter
   
End Sub
Sub DeleteFromBondStore(ByVal strNSVCode As String, ByVal strBatchNumber As String)
'27Aug13 TH Written to delete records in the Bond Store table
'           This is to allow a retunr which will remove the item from bondstore (TFS 72012)
Dim strParams As String
Dim lngResult As Long


   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode) & _
              gTransport.CreateInputParameterXML("Batchnumber", trnDataTypeVarChar, 25, strBatchNumber)
   lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyBondStoreDeletebySiteIDNSVCodeBatch", strParams)
   

End Sub

