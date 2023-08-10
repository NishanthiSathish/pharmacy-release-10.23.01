Attribute VB_Name = "StockEnquiryDISP"
'---------------------------------------------------------------------------------------
'                      Stock Enquiry from Dispensing
'---------------------------------------------------------------------------------------
'17oct08 CKJ Ported minimum from stores to dispensing to support drug enquiry.
'            Custom orderlib added (called OrderLibDISP) and pruned to the max.
'            Custom wOrderIO added (called wOrderDISP) with CLOSE and END removed.
'            Remaining necessary bits of stores placed here in StockEnquiryDISP.
'            OrdInfo.frm added
'23Jun08 XN  F0033906 Now used the ICW desktop F4 screens.
'17Oct14 XN  SiteDrugEnquiryDISP: 88560 Prevented user from searching for drug via BNF (findrdrug)

Option Explicit
DefBool A-Z

Global sitenos() As Integer
Global siteabb$(), sitepth$()
Global sup As supplierstruct
Global PrintInPacks As Integer
'

Sub SiteDrugEnquiryDISP(ByVal drugcode As String, ByVal passlevel As Integer)
'30Sep99 AE  corected output to use the variable Stocklvl$ instead of d.stocklevel. ALso generally tidied
'            up output.
'26Mar01 TH  Reset Wslist.mdb to correct site
'14Jan02 TH  Stop error when resettinmg Ward Stock list mdb to Original site from stores - pragmatic solution (#57914,#57438)
'   "        because it is difficult to know what data objects association with the wslist are actually open at this time
'   "        Also more importantly the WSList is reopened for the correct site afterwards - I had made the above change stupidly
'   "        only from a dispensary perspective - Sorry. This should now ensure the wslist is correct after the site enquiry.
'17oct08 CKJ Ported minimum from stores to dispensing to support drug enquiry.
'            This proc now uses params instead of command$
'17Oct14 XN  88560 Prevented user from searching for drug via BNF (findrdrug)

Dim mnu$(), ans$, temp$, temp1$, savedrug$, drug$
Dim hlp%()
Dim numofsites%, count%, DrugPtr&, found%, ExitLoop%   '01Jun02 ALL/ATW
Dim founditem&, stocklvl$, pathfound%    '01Jun02 ALL/ATW
Dim TmpSitenumber As Long
Dim intFound As Integer '24Aug05 TH Added
Dim strDate As String '12Dec05 TH Added
Dim strStoresDescription As String

   ReadSites
   
   numofsites = UBound(sitenos%)
   ReDim mnu$(numofsites)
   ReDim hlp%(numofsites)
   
   drugcode = Trim$(drugcode)
   If Len(drugcode) = 0 Then
      setinput 0, k
      k.Max = 13
      k.min = 0
      k.helpnum = 360
      InputWin "Site Drug Enquiry", "Enter item code ", drugcode, k
      drugcode = Trim$(drugcode)

      If Not k.escd And Len(drugcode) > 0 Then
         'findrdrug "", 0, d, 0, intFound, 0, False, False     17Oct14 XN 88560 Prevented user from searching for drug via BNF (findrdrug)
         findrdrug "", 0, d, 0, intFound, 0, False, False, False
         If intFound Then ODrugInfo$ = d.SisCode
         savedrug$ = ODrugInfo$
      End If
   Else
      ODrugInfo$ = drugcode
      savedrug$ = ODrugInfo$
   End If
   
   If Len(ODrugInfo$) Then
      If numofsites > 0 Then
         temp$ = dispdata$
         TmpSitenumber = SiteNumber
         For count = 1 To numofsites
            If ODrugInfo$ <> "" Then
               d.SisCode = ODrugInfo$
               LstBoxFrm.lblHead = "Site           " & TB & "Stock level" & TB & "Owed   " & TB & "Date last ordered"
               CheckPath sitepth$(count), pathfound%
               If pathfound Then
                  SetDispdata sitenos%(count)
                  'SQL TO DO - Nudge the SessionSite Table here
                  getdrug d, 0, founditem, False
                  If founditem Then
                     stocklvl$ = Iff(Trim$(d.stocklvl) = "", "0", d.stocklvl) '''& TB & TB
                     'If strStoresDescription = "" Then                    '17oct08 CKJ strStoresDescription was never pre-set
                     '   strStoresDescription = d.storesdescription        '   "
                     '   plingparse strStoresDescription, "!"              '   "
                     '   LstBoxFrm.Caption = strStoresDescription          '   "
                     'End If                                               '   "
                     LstBoxFrm.Caption = "Stock Enquiry"                   '17oct08 CKJ improved function & layout
                     strStoresDescription = d.DrugDescription              '   strStoresDescription = GetStoresDescription()  XN 4Jun15 98073 New local stores description
                     plingparse strStoresDescription, "!"                  '   "
                     LstBoxFrm.lblTitle = cr & strStoresDescription & cr   '   "

                     parsedate d.lastordered, strDate, 1, 0             '17oct08 CKJ moved line inside the IF
                     LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & Trim$(stocklvl$) & TB & d.outstanding & TB & strDate
                  Else
                     'stocklvl$ ="Item not stocked on this site"                                           '17oct08 CKJ removed
                     LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & "Item not stocked on this site"       '17oct08 CKJ added
                  End If
                  'parsedate d.lastordered, strDate, 1, 0
                  'LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & Trim$(stocklvl$) & TB & d.outstanding & TB & strDate   '17oct08 CKJ removed
               Else
                  LstBoxFrm.LstBox.AddItem siteabb$(count) & TB & "Not connected to this workstation"
               End If
            Else
               LstBoxFrm.LstBox.AddItem siteabb$(count)
               LstBoxFrm.lblHead = "Site"
            End If
         Next
         dispdata$ = temp$
         SiteNumber = TmpSitenumber
         SetDispdata 0
         
         LstBoxShow '22Feb07 TH Moved out of loop
         Do
            'LstBoxShow
            ans$ = Format$(LstBoxFrm.LstBox.ListIndex + 1)
                                                                                    
            If Val(ans$) = 0 Then
               ans$ = ""
               k.escd = True
               ExitLoop = True
            Else
               k.escd = False
               ExitLoop = False
               temp$ = dispdata$
               temp1$ = hospabbr$
               dispdata$ = sitepth$(Val(ans$))
               hospabbr$ = siteabb$(Val(ans$))
               '''sitenos% (Val(ans$))
               
               'Now set sitenumber
               ''TmpSitenumber = SiteNumber
                              
               SetDispdata sitenos%(Val(ans$)) '24Aug05 TH Added
               ''sitenumber = GetSiteIDFromDispdata(Val(Right$(dispdata$, Mid$(dispdata$, InStr(1, dispdata$, ".", vbBinaryCompare)) + 1)))
               'SQL TO DO - Nudge the SessionSite Table here
               If SiteNumber = 0 Then
                  popmessagecr "EMIS Health", "Site not properly configured - cannot view information"
                  k.escd = True
               End If
               drug$ = savedrug$ '24Aug05 TH Added
               ''If Not k.escd Then
               
               If Not k.escd And (Trim$(savedrug$) = "") Then
                   k.Max = 13
                   k.min = 2
                   drug$ = savedrug$
                   k.helpnum = 50
                   InputWin hospabbr$, "Enter item code       ", drug$, k
               End If
               If Not k.escd Then
                  CheckPath dispdata$, pathfound%                                                                             '26Dec98
                  If pathfound Then                                                                                           '  "
                     'findrdrug drug$, 1, d, DrugPtr, found, 2, False, False     17Oct14 XN 88560 Prevented user from searching for drug via BNF (findrdrug)
                     findrdrug drug$, 1, d, DrugPtr, found, 2, False, False, False                                                              '  "
                     If found Then
                        savedrug$ = d.SisCode
                        ODrugInfo$ = d.SisCode
                        DisplayDrugEnquiry ODrugInfo$, sitenos%(Val(ans$)) ' Removed using DrugInfo.frm as now displayed via ICW desktop F0033906
                        'Load DrugInfo
                        'DrugInfo.Show 1
                        On Error GoTo 0
                     Else
                        popmessagecr "#Product Enquiry", "Product not stocked on this site"    '17oct08 CKJ added
                     End If
                  Else
                     dispdata$ = temp$
                     popmessagecr "Error on " & sitepth$(Val(ans$)), "This workstation is not connected to " & hospabbr$
                  End If
               End If
               dispdata$ = temp$
               hospabbr$ = temp1$
               SiteNumber = TmpSitenumber
            End If
            If Not ExitLoop Then LstBoxFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form '22Feb07 TH Added
         Loop While Not ExitLoop
         Unload LstBoxFrm                                                                                            '     "
         k.escd = False
         SiteNumber = TmpSitenumber '10Jan07 TH RESET SITE !!!!
         SetDispdata 0              '  "
      End If
   End If

End Sub


Sub CheckPath(pathchecked$, found%)
'26Dec98 ASC checks to see if a path is available
Dim filespec$

   found = True
   On Error GoTo NoPath
   filespec$ = Dir$(pathchecked$, 16) 'checks for directory only
   On Error GoTo 0

Exit Sub
                                             
NoPath:
   found = False
Resume Next

End Sub

