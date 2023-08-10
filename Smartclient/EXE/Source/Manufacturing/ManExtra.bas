Attribute VB_Name = "ManExtra"
Option Explicit


Public Sub UpdatePanel(ByRef d As DrugParameters)




   If TrueFalse(terminal("DisplayManufacturingPanel", "Y")) Then
      
         FillHeapDrugInfo gPRNheapID, d, 0
      ConstructInfoDisplay dispdata$ & "\IngPanel.ini", "IngredientInfo", ManIssue.PicInfo1, 0
      'ConstructInfoDisplay dispdata$ & "\OrdPanel.ini", "SupplierInfo", MainScreen.PicInfo2, intStatus
   End If

End Sub
Private Sub ConstructInfoDisplay(strPathfile As String, strSection As String, ctlDisplay As Control, ByVal intStatus As Integer)
'31Jan03 TH (PBSv4) Written / merged
'31Jan03 TH (PBSv4) MERGED

Dim intFound As Integer, strTmp As String, intCount As Integer, intEntry As Integer, ReadOnly%, intDummy
Dim intCharCount As Integer, strValue As String
Dim intOK As Integer, strSql As String
Dim strPBSAuthNum As String, strPBSOrigNum As String
Dim intmaxline As Integer
Dim intNumOfEntries As Integer
Dim intRows As Integer
Const rowheight = 260

   'ctlDisplay.Height = 230
   ctlDisplay.Height = rowheight
   If ctlDisplay.Width < 10000 Then
      intmaxline = 112 '73 '112
   Else
      intmaxline = 148
   End If

   ReDim strItems(2) As String
   intNumOfEntries = Val(TxtD(strPathfile, strSection, "", "Lines", intFound))
   If intNumOfEntries = 0 Then
      intNumOfEntries = Val(TxtD(strPathfile, strSection, "", "Lines", intFound))
   Else
      strSection = strSection '& Format$(intStatus)
   End If
   If intNumOfEntries = 0 Then ctlDisplay.Visible = False: Exit Sub
   
   ctlDisplay.AutoRedraw = True
   ctlDisplay.tabstop = False
   ctlDisplay.Cls
   ctlDisplay.Visible = True
   
   For intCount = 1 To intNumOfEntries
      strTmp = TxtD(strPathfile, strSection, "", Format$(intCount), intFound)
      ReDim strItems(2)
      strValue = ""
      deflines strTmp, strItems(), "|", 0, (intDummy)
      If Trim$(strItems(1)) <> "" Then
         If LCase$(Trim$(strItems(0))) = "crlf" Then
            ctlDisplay.Height = ctlDisplay.Height + 230
            ctlDisplay.Print
         Else
            If Trim$(strItems(1)) <> "" Then
               If LCase$(Trim$(strItems(1))) = "crlf" Then
                  'ctlDisplay.Height = ctlDisplay.Height + 230
                  ctlDisplay.Height = ctlDisplay.Height + rowheight
                  ctlDisplay.Print
               Else
                  Heap 11, gPRNheapID, strItems(1), strValue, 0
                  If strValue = "" Then strValue = TxtD(strPathfile, strSection, "Blank", "DefaultScreenValue", 0)
                  intCharCount = intCharCount + Len(strItems(0)) + Len(strValue) + 5
                  If intCharCount > intmaxline Then
                     'ctlDisplay.Height = ctlDisplay.Height + 230
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
         End If
      End If
   Next
   'intRows = Val(terminal("IngPanelRows", "0"))
   If Val(TxtD(strPathfile, strSection, "0", "FixedScreenHeight", 0)) > 0 Then
       ctlDisplay.Height = Val(TxtD(strPathfile, strSection, "0", "FixedScreenHeight", 0))
   Else
      intRows = Val(TxtD(strPathfile, strSection, "0", "Lines", 0))
      If intRows > 0 Then
         'ctlDisplay.Height = intRows * 230
         ctlDisplay.Height = intRows * rowheight
      End If
   End If
   ReDim strLines(0)

End Sub
Public Sub blankIngScreen()
ManIssue.PicInfo1.Visible = False
ManIssue.PicInfo1.Cls

End Sub

