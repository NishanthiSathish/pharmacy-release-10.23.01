VERSION 5.00
Begin VB.Form DrugInfo 
   Appearance      =   0  'Flat
   Caption         =   "Form1"
   ClientHeight    =   11100
   ClientLeft      =   3795
   ClientTop       =   4080
   ClientWidth     =   9495
   BeginProperty Font 
      Name            =   "Courier New"
      Size            =   9.75
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "ORDINFO.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   11100
   ScaleWidth      =   9495
   Begin VB.Frame FraInfoMiddle 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "Frame2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   3255
      Left            =   0
      TabIndex        =   5
      Top             =   2160
      Width           =   9495
      Begin VB.ListBox LstInfoMiddle 
         Appearance      =   0  'Flat
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   2340
         Left            =   120
         TabIndex        =   6
         TabStop         =   0   'False
         Top             =   240
         Width           =   9255
      End
   End
   Begin VB.Frame FraInfoTop 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   2175
      Left            =   0
      TabIndex        =   3
      Top             =   0
      Width           =   9495
      Begin VB.ListBox LstInfoTop 
         Appearance      =   0  'Flat
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1290
         Left            =   120
         TabIndex        =   4
         Top             =   360
         Width           =   9315
      End
   End
   Begin VB.Frame FraInfoLarge 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      Caption         =   "Frame1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   6615
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   9495
      Begin VB.Label LblInfoLarge 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   4575
         Left            =   120
         TabIndex        =   2
         Top             =   360
         Width           =   9135
      End
   End
   Begin VB.PictureBox picInfo 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   2385
      Left            =   0
      ScaleHeight     =   2385
      ScaleWidth      =   9495
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   6630
      Width           =   9495
   End
End
Attribute VB_Name = "DrugInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'                            ORDINFO.FRM
'                            -----------
'
'16Jan98 EAC KeyActions : Handle Printing Requisitions in Packs
'26May98 CFY Form_Load: Added Dp! to correct rounding errors in stock levels before displaying
'12Jun98 CKJ KeyActions: Removed Format$(Val(...))    !!** Must check all instances of Format$(Val(...))
'30Jun98 EAC KeyActions: Handle part pack issues so that quantities aren't display as decimals
'30Jun98 EAC KeyActions: items that don't have an order num are shown as blank lines (ie Pick tick = N, Del Note = Y)
'18Aug98 TH  Form_Load: Removed condition so as to show 0 priced items
'28Aug98 TH  KeyActions: Formatted losses/gains so as to deal with negative values
'23Nov98 TH  Form_Load: Added Date last ordered and date last issued to Info panels
'22Jan99 TH  Form_Load: Format stocklevel in packs to two decimal places
'26Jan99 TH  Form_Load: Changed layout of received info
'26Jan99 TH  KeyActions: Changed layout of received info
'23Feb99 TH  Form_Load: & KeyActions: Added Cr Affix to make credits more obvious
'01Mar99 TH  KeyActions: Force retention of height of listboxes
'08Mar99 TH  Form_Load: Added site abbreviation to title bar
'17May99 AE  Form_Load:Improved formatting of d.leadtime on screen
'    "       Form_Load:More sensible formatting of d.stocklvl on screen
'11Oct99 CKJ Removed Findsupplier, replaced with GetSupplier
'15Sep00 TH  Form_Load: Format stocklevel to 6 sig places
'18Sep00 TH  KeyActions: Added dp to format of received and outstanding quantities
'14Feb02 ATW KeyActions: Added Supplier telephone number to page three of stock report   (ENHDB 1137)
'08jul02 ckj removed all references to fontname and fontsize
'            changed all references to DrugInfo. to Me.
'            KeyActions: removed loops - use .Clear instead
'            corrected indenting of source
'11Jul02 CKJ Mods throughout:
'            form is resizable & makes good use of 1024x768 screens
'            panel and lists updated from one place only - avoids info changing on second pass
'            panel does not use 3D control, columns movable, bold & headings selectable
'            winord.ini
'            [ItemEnquiry]
'            InfoPanelTitleBold=N            'Bottom panel text like "Cost:"
'            InfoPanelDataBold=Y             'Bottom panel data like "£1.43"
'            InfoPanelColumn1=1              'Bottom panel columns (numbers are x100 twips)
'            InfoPanelColumn2=13             '
'            InfoPanelColumn3=40             '
'            InfoPanelColumn4=56             '
'            InfoPanelColumn5=80             '
'            InfoPanelColumn6=92             '
'            InfoPanelListTitle1="..."       'Listbox caption: Orders to authorise
'            InfoPanelListTitle2="..."       'Listbox caption: Orders authorised
'            InfoPanelListTitle3="..."       'Listbox caption: Goods due out
'            InfoPanelListTitle4="..."       'Listbox caption: Goods issued
'14Oct02 CKJ DisplayScreen1or2: Added space between order number and date
'16May04 TH  DisplayScreen3: ,DisplayPanel:,DisplayScreen1or2:  Added mod to suppress cost if configured (UMMC price hide)
'27May04 TH  DisplayScreen3: ,DisplayPanel:,DisplayScreen1or2:  Above mod now uses hideprice wrapper
'17oct08 CKJ DisplayScreen3: minor layout tweak on 3rd page (font & leading space)
'03Aug10 XN  DisplayPanel: F0088717 Stores only product now identified if the ProductID=0 so updated handling in the display.
'11Jul11 CKJ Merged from V8.9: 16Jun05 CKJ MechDispStockEnquiry: written   DisplayScreen3: Added stock locations

Option Explicit
DefInt A-Z

Const modulename$ = "ORDINFO.FRM"

Dim ord As orderstruct
Dim td As DateAndTime
Dim dt As DateAndTime

Dim m_intScreenNumber As Integer
Dim DrugPtr&, orddebug%   ' 01Jun02 ALL/ATW
Dim drug$

Dim strRobotStock As String

Private Sub DisplayInfoByColumn(ctlDisplay As Control, ByVal strInfo As String, ByVal intColumn As Integer, ByVal blnBold As Integer)
'11jul02 CKJ written
'            Pass in a picture box or similar, string to display, column number and bold flag
'            string can be multiline, separated by "[cr]" or by cr or crlf
'            column is an approximate column number, and is multiplied by 100 to give twips
'            bold = true/false

Dim intNumofLInes As Integer
Dim intline As Integer
      
   ReDim strLines(10) As String
   
   If intColumn < 0 Then
         ctlDisplay.Cls
      Else
         replace strInfo, "[cr]", cr, 0
         ctlDisplay.CurrentY = 75
         replace strInfo, lf, "", 0
         deflines strInfo, strLines(), cr & "(*)", 1, intNumofLInes
         ctlDisplay.FontBold = (blnBold <> 0)
         For intline = 1 To intNumofLInes
            ctlDisplay.CurrentX = 100 * intColumn
            ctlDisplay.Print strLines(intline)
         Next
      End If
   ctlDisplay.Refresh

End Sub

Private Sub DisplayPanel()
'11jul02 CKJ Derived from two original procedures
'16May04 TH  Added mod to suppress cost if configured (UMMC price hide)
'27May04 TH  Above mod now uses hideprice wrapper
'03Aug10 XN  F0088717 Stores only product now identified if the ProductID=0 so updated handling in display.
'15Jun05 CKJ Added Robot stock enquiry on F4
Dim pform$, packs$, cost$, txt$, Outer$, blnTitleBold As Integer, blnDataBold As Integer
Dim strInifile As String, strSection As String
Dim strTemp As String
Dim MachineType As String

   strInifile = dispdata$ & "\winord.ini"
   strSection = "ItemEnquiry"
   blnTitleBold = TrueFalse(TxtD(strInifile, strSection, "0", "InfoPanelTitleBold", False))
   blnDataBold = TrueFalse(TxtD(strInifile, strSection, "-1", "InfoPanelDataBold", False))
                
   DisplayInfoByColumn Me.picInfo, "", -1, 0               'clear the info panel
   
   pform$ = LCase$(Trim$(d.PrintformV))
   packs$ = " x " & Trim$(d.convfact) & " " & pform$
   drug$ = d.SisCode  '15Nov92 ASC

   'set information in first column at bottom of screen
   txt$ = "Cost:[cr]NSV:[cr]Code:[cr]Locations:[cr]Lead time:[cr]Order cycle:[cr]Tracking:[cr]Tradename:[cr]Notes [F2]:"
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "1", "InfoPanelColumn1", False)), blnTitleBold
   
   cost$ = Str$(dp!(Val(d.cost) / 100))
   poundsandpence cost$, True
   'If (truefalse(txtd$(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then cost$ = " *****"  '16May04 TH Added
   txt$ = money(5) & HidePrice(Trim$(cost$), True) & " for 1" & packs$ & cr & d.SisCode & cr & d.Code & cr & d.loccode '27May04 TH Added HidePrice and replaced above
   If Len(Trim$(d.loccode2)) Then txt$ = txt$ & ", " & d.loccode2
   txt$ = txt$ & cr & FormatVal$(d.leadtime, 1, 3) & " days" & cr '117May99 AE changed formatting of d.leadtime
   If Len(Trim$(d.ordercycle)) Then
         txt$ = txt$ & Trim$(d.ordercycle) & " every " & d.cyclelength & " days"
      Else
         txt$ = txt$ & "Not on cyclical ordering"
      End If
   
   Select Case Val(d.batchtracking)
      Case 2:    strTemp = "Batch number on receipt"        'Record Batchnumber on receipt
      Case 3:    strTemp = "Batch & expiry on receipt"      'Record Batchnumber and expiry date on receipt
      Case 4:    strTemp = "Batch/expiry on receipt/issue"  'Record Batchnumber and expiry date on receipt and confirm on Issue
      Case Else: strTemp = "Not on batch tracking"          'No Batch Tracking
      End Select
   txt$ = txt$ & cr & strTemp & cr & d.tradename & cr & Trim$(d.message)
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "13", "InfoPanelColumn2", False)), blnDataBold
         
   'set information in second column at bottom of screen
   txt$ = "Stock level:[cr]Reorder level:[cr]Outer size:[cr]Outstanding:[cr]Annual usage:[cr]Date last ordered:[cr]Date last issued:"
   
   '16Jun05 CKJ Added block. Is product stocked in a Robot?
   If LocationForMechDisp(d.loccode, MachineType) Then
         txt = txt & "[cr]" & MachineType & " [F4]:"
      End If
   
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "40", "InfoPanelColumn3", False)), blnTitleBold
         
   Outer$ = Trim$(d.reorderpcksize)
   If Outer$ = "" Then Outer$ = "1"
   txt$ = FormatVal$(d.stocklvl, 2, 6) & " " & pform$            '20Sep00 TH Missed this the first time around
   If Trim$(d.storespack) = "" Then d.storespack = "Pack"                                                                     '27Feb98 ASC
   txt$ = txt$ & "  (or " & FormatVal$(Format$(dp!(Val(d.stocklvl) / Val(d.convfact))), 2, 6) & " " & Trim$(d.storespack) & ")" & cr  '15Sep00 TH  Format stocklevel to 6 sig places
   
   txt$ = txt$ & Trim$(d.reorderlvl) & " " & pform$ & cr & Outer$
   If Trim$(d.convfact) = "1" Then
         txt$ = txt$ & " " & pform$
      Else
         txt$ = txt$ & packs$
      End If

   txt$ = txt$ & cr & Format$(d.outstanding, "0.###")  '10Dec97 EAC format d.outstanding to 6 places
   If d.outstanding Then
         txt$ = txt$ & packs$
      Else
         txt$ = txt$ & " " & pform$
      End If
   txt$ = txt$ & cr & Trim$(Str$(Int(1& * Val(d.anuse)))) & " " & pform$ & cr
   txt$ = txt$ & Format$(d.lastordered, "##/##/####") & cr     '23Nov98 TH Added
   txt$ = txt$ & Format$(d.lastissued, "##/##/####") & cr      '23Nov98 TH Added
                          
   '16Jun05 CKJ Added block - Robot stock level
   If LocationForMechDisp(d.loccode, MachineType) Then
         txt$ = txt$ & cr
         If Len(strRobotStock) Then
               txt$ = txt$ & strRobotStock
               If Trim$(d.convfact) = "1" Then
                     txt$ = txt$ & " " & pform$
                  Else
                     txt$ = txt$ & packs$
                  End If
            End If
      End If
   
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "56", "InfoPanelColumn4", False)), blnDataBold
   
   'set information in third column at bottom of screen
   txt$ = "[cr]Live:[cr]Stocked:[cr]In use:[cr]Formulary:[cr]Cytotoxic:[cr]Reorder calc:"
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "80", "InfoPanelColumn5", False)), blnTitleBold
   
   txt$ = cr & d.livestockctrl & cr
   txt$ = txt$ & d.sisstock & cr
   txt$ = txt$ & Iff((d.inuse = "Y") And (d.ProductID = 0), "S", d.inuse) & cr  ' 3Aug10 XN F0088717 Stores only product now identified by if the ProductID=0
   txt$ = txt$ & d.formulary & cr
   txt$ = txt$ & d.cyto & cr
   txt$ = txt$ & d.recalcatperiodend
   DisplayInfoByColumn Me.picInfo, txt$, Val(TxtD(strInifile, strSection, "92", "InfoPanelColumn6", False)), blnDataBold
   
End Sub

Private Sub DisplayScreen1or2(ByVal intScreenNumber As Integer)

Dim loopstart%, displayed%, pass%, edtype%, skip% '' foundsup%,
Dim orddat$, recdat$, txt$, paydat$, gap$, tempcost$
Dim cont&, fnd&
Dim DisplayQty!, PartPack%
Dim strParams As String
Dim rsOrders As ADODB.Recordset
Dim strOrdNum As String
Dim strInvnum As String
Dim strSort As String '06Jun08 TH Added
   
   Me.LstInfoTop.Clear
   Me.LstInfoMiddle.Clear
   
   If intScreenNumber = 1 Then
         Me.FraInfoTop.Caption = FormatHeading("1", "   Ordered" & Space$(27) & "Qty [#####] Site  ")
         'Me.FraInfoMiddle.Caption = FormatHeading("2", "  Num        Ord Date   Date Rec       Qty Rec   Sup    Inv date   Inv. No.      Cost  ")
         Me.FraInfoMiddle.Caption = FormatHeading("2", " Num     Ord Date   Date Rec      Qty Rec     Sup   Inv date   Inv. No.      Cost  ")
         loopstart = 1
      Else
         Me.FraInfoTop.Caption = FormatHeading("3", "   Due out  ")
         Me.FraInfoMiddle.Caption = FormatHeading("4", "   Issued  ")
         loopstart = 3
      End If
      
   For pass = loopstart To loopstart + 1     'either 1 & 2 or 3 & 4
      Select Case pass
         Case 1: edtype = 3
         Case 2: edtype = 4
         Case 3, 4: edtype = 5
      End Select
      
      displayed = False
      cont& = 0
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Code", trnDataTypeVarChar, 7, d.SisCode)
      Select Case pass
         Case 1:
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWOrderbyCode", strParams)
         Case 2:
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWReconcilbyCode", strParams)
         Case 3, 4:
            Set rsOrders = gTransport.ExecuteSelectSP(g_SessionID, "pWRequisbyCode", strParams)
      End Select
      If rsOrders.RecordCount > 0 Then
         '06Jun08 TH Added (F0015752)
         Select Case pass
            Case 1:
               strSort = TxtD(dispdata$ & "\winord.ini", "ItemEnquiry", "", "WOrderSort", False)
            Case 2:
               strSort = TxtD(dispdata$ & "\winord.ini", "ItemEnquiry", "", "WReconcilSort", False)
            Case 3, 4:
               strSort = TxtD(dispdata$ & "\winord.ini", "ItemEnquiry", "", "WRequisSort", False)
         End Select
         If Trim$(strSort) <> "" Then
            rsOrders.Sort = strSort
         End If
         '-----------------
         rsOrders.MoveFirst
         Do While Not rsOrders.EOF
            'SQL If necessary the rs could be just a list of IDs
             Select Case pass
               Case 1: ord = FillOrdFromRS(rsOrders, "WOrder")
               Case 2: ord = FillOrdFromRS(rsOrders, "WReconcil")
               Case 3, 4: ord = FillOrdFromRS(rsOrders, "WRequis")
            End Select
            
            ''getorder ord, (fnd&), edtype, False       ' (uses idx)
            If orddebug Then poporder ord, "Drug Information Debug"
            getsupplier ord.supcode, 0, 0, sup
            orddat$ = ord.orddate
            convdat orddat$
            recdat$ = ord.recdate
            convdat recdat$
            Select Case pass
               Case 1, 2                      'pass = 1 on order, 2 received
                  Select Case ord.status
                     Case "3"
                        displayed = True
                        If Len(ord.num) < 8 Then
                           strOrdNum = Left$(Trim$(ord.num), 7)
                        Else
                           strOrdNum = ord.num
                        End If
                        txt$ = " " & strOrdNum & " " & orddat$ & "          " & Right$("       " & Format$(dp(Val(ord.outstanding))), 7) & " x " & d.convfact & "  " & ord.supcode & "  " & sup.name '18Sep00 TH Added dp to format outstanding
                        If Trim$(ord.invnum) <> "" Then txt$ = txt$ & " Supp. ord: " & Trim$(ord.invnum)
                        LstInfoTop.AddItem txt$

                     Case "4", "7", "8"
                        displayed = True
                        paydat$ = ord.paydate
                        '23Nov05 TH Added padding
                        strInvnum = Trim$(ord.invnum)
                        'pad to 10 if required
                        If Len(strInvnum) < 13 Then
                           strInvnum = strInvnum & Space$(13 - Len(strInvnum))
                        End If
                        convdat paydat$
                        gap$ = Space$(7)
                        If Val(ord.outstanding) <> 0 Then gap$ = gap$ & Chr$(164)
                        If Len(Trim$(ord.num)) < 8 Then
                           strOrdNum = Left$(ord.num, 7)
                        Else
                           strOrdNum = ord.num
                        End If
                        txt$ = " " & strOrdNum & " " & orddat$ & " " & recdat$ & Right$(gap$ & Format$(dp(Val(ord.received))), 7) & " x " & d.convfact & " " & ord.supcode & " " & paydat$ & " " & strInvnum      '18Sep00 TH Added dp to format received '14Oct02 CKJ Added space
                        tempcost$ = Str$(dp!(Val(ord.cost) / 100!))
                        poundsandpence tempcost$, False
                        tempcost$ = Trim$(tempcost$) '23Nov05 TH Added
                        If Val(ord.qtyordered) < 0 Then
                           txt$ = txt$ & "-" & Trim$(money(5)) & HidePrice(tempcost$, False) & " Cr"
                        Else
                           txt$ = txt$ & " " & Trim$(money(5)) & HidePrice(tempcost$, False)
                        End If
                        Me.LstInfoMiddle.AddItem txt$
                  End Select

               Case 3, 4                      'pass 3 = due out or 4 = issued
                  Select Case ord.status
                     Case "5", "6", "7", "8", "R"  'pass 3=(5,6)  pass 4=(7,8,R) '18Feb94 CKJ was D not R
                        skip = False
                        Select Case ord.status
                           Case "5", "6"
                              If pass = 4 Then skip = True
                           Case Else
                              If pass = 3 Then skip = True
                           End Select

                        If Not skip Then        ' NNNN -ORD-DATE-  -REC-DATE- QUANTY x CONVF UNITS  SUPLR  SUPNAME....'
                           displayed = True
                           '30Jun98 EAC items that don't have an order num are shown as blank lines
                           'txt$ = " " & pad(trimz$(ord.num), 5) & orddat$ & "  " & recdat$ & " "
                           txt$ = " " & pad(trimz$(ord.num), 13) & orddat$ & "  " & recdat$ & " " '23Nov05 Added extra pad on num
                           PartPack = False
                           Select Case ord.status
                              Case "5", "6": DisplayQty! = Val(ord.outstanding)
                              Case Else:     DisplayQty! = Val(ord.received)
                           End Select

                           If CLng(DisplayQty! * Val(d.convfact)) Mod Val(d.convfact) <> 0 Then
                              DisplayQty! = CLng(DisplayQty! * Val(d.convfact))
                              PartPack = True
                           End If
                           txt$ = txt$ & rightjust6(Format$(DisplayQty!))
                           If (UCase$(sup.suppliertype) = "W" Or UCase$(sup.suppliertype) = "L") And Not PrintInPacks Or PartPack Then   '16Jan98 EAC Added suppliertype L and PrintInPacks '30Jun98 EAC added or PartPack
                              txt$ = txt$ & "        "
                           Else
                              txt$ = txt$ & " x " & d.convfact
                           End If
                           txt$ = txt$ & " " & d.PrintformV & "  " & ord.supcode & "  " & sup.name
                           If pass = 3 Then
                              Me.LstInfoTop.AddItem txt$
                           Else
                              txt$ = txt$ & " " & Format$(ord.pickno)
                              Me.LstInfoMiddle.AddItem txt$
                           End If
                        End If
                  End Select
            End Select
            rsOrders.MoveNext
         Loop
      End If
      If Not displayed Then
            Select Case pass
               Case 1: Me.LstInfoTop.AddItem "    Not on order"
               Case 2: Me.LstInfoMiddle.AddItem "    No completed orders on record"
               Case 3: Me.LstInfoTop.AddItem "    None owed to other sites"
               Case 4: Me.LstInfoMiddle.AddItem "    No issue information on record"
               End Select
         End If
   Next
      
   Me.FraInfoTop.Visible = True
   Me.FraInfoMiddle.Visible = True
   Me.FraInfoLarge.Visible = False

End Sub

Private Sub DisplayScreen3()
'11jul02 CKJ Derived from original KeyActions procedure
'16May04 TH  Added mod to suppress cost if configured (UMMC price hide)
'27May04 TH  Above mod now uses hideprice wrapper
'17oct08 CKJ minor layout tweak for leading space

Dim txt$, cost$, pform$, packs$, dailyuse!, daysleft!, expdate$ ''foundsup%,
Dim strAlternativeSuppliers As String

   pform$ = LCase$(Trim$(d.PrintformV))
   packs$ = " x " & Trim$(d.convfact) + " " + pform$

   cost$ = Str$(dp!(Val(d.sislistprice) / 100))
   poundsandpence cost$, False
   txt$ = " Last received at   " & money(5) & HidePrice(Format$(Val(cost$), "0.00"), True) & cr
   
   cost$ = Str$(dp!(Val(d.lastreconcileprice) / 100))
   poundsandpence cost$, False
   txt$ = txt$ & "  Last reconciled at " & money(5) & HidePrice(Format$(Val(cost$), "0.00"), True) & cr
   
   cost$ = Str$(dp!(d.lossesgains / 100))
   cost$ = Format$(Format$(dp!(d.lossesgains / 100)), "###0.00")      '
   txt$ = txt$ & "  Gains/Losses       " & money(5) & HidePrice(cost$, True) & cr
   
   If Trim$(d.contno) <> "" Then txt$ = txt$ & cr
   txt$ = txt$ & "  Contract           " & d.contno & cr
   
   cost$ = Str$(dp!(Val(d.contprice) / 100))
   poundsandpence cost$, False
   txt$ = txt$ & "  Contract price     " & money(5) & HidePrice(Format$(Val(cost$), "0.00"), True) & cr & cr
   txt$ = txt$ & "  " & money(9) & " rate           " & d.vatrate
   txt$ = txt$ & "     " & Trim$(Str$(100 * (VAT(Val(d.vatrate)) - 1))) & "%" & cr & cr
   txt$ = txt$ & "  Minimum issue      " & d.minissue & "   " & pform$ & cr
   txt$ = txt$ & "  Maximum issue      " & d.maxissue & "  " & pform$ & cr
   txt$ = txt$ & "  Reorder quantity   " & d.reorderqty & packs$ & cr & cr
   txt$ = txt$ & "  BNF code           " & RTrim$(d.bnf) & cr
   txt$ = txt$ & "  Ledger code        " & d.ledcode & cr
   txt$ = txt$ & "  Therapeutic code   " & d.therapcode & cr
   txt$ = txt$ & "  Disp. pack size   " & Str$(d.mlsperpack) & cr & cr

   getsupplier d.supcode, 0, 0, sup
   txt$ = txt$ & "  Primary supplier   "
   txt$ = txt$ & d.supcode & "  " & sup.name & "  Tel. : " & sup.suptelno & cr
   txt$ = txt$ & "  Order method  " & sup.Method & cr
   strAlternativeSuppliers = GetAltenativeSupplierString(d.SisCode)
   txt$ = txt$ & "  Other suppliers    " & strAlternativeSuppliers & cr
      
   'out of stock = today + ((stock level - outstanding) / rate of usage)
   dailyuse! = Val(d.anuse) / 365.25
   If dailyuse! Then
         daysleft! = (Val(d.stocklvl) - d.outstanding) / dailyuse!
         If daysleft! >= 0 And Abs(daysleft!) < 32767 Then
               txt$ = txt$ & "  Est. out of stock  "
               today td
               dt.mint = daysleft! * mind
               AddExpiry td, dt
               DateToString td, expdate$
               If daysleft! <= Val(d.leadtime) Then txt$ = txt$ & " "
               txt$ = txt$ & expdate$
            End If
      End If

   txt$ = txt$ & cr                                                        '16Jun05 CKJ Added stock locations
   txt$ = txt$ & " Stock locations    Primary: " & Trim$(d.loccode)
   txt$ = txt$ & "   Secondary: " & d.loccode2 & cr
               
   Me.FraInfoLarge.Caption = ""
   Me.LblInfoLarge.Caption = txt$
   Me.FraInfoLarge.Visible = True
   Me.FraInfoMiddle.Visible = False
   Me.FraInfoTop.Visible = False

End Sub

Private Sub DisplayScreen4()
'11jul02 CKJ Derived from original KeyActions procedure
'            Uses snapshot instead of dynaset
'            Needs better SQL
'DO NOW YOU BONE HEAD !!!

Const procname$ = "DisplayScreen4"

Dim SQL$, txt$, count%
Dim rsWards As ADODB.Recordset
Dim strParams As String


   On Error GoTo DisplayScreen4_Err
   'SQL THIS SHOULD USE gStockSite !!!!!!
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, drug$)
   Set rsWards = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListForDrugInfo", strParams)
   
   txt$ = ""
   count = 0
   If rsWards.RecordCount > 0 Then
   Do While Not rsWards.EOF
      txt$ = txt$ & RtrimGetField(rsWards!SiteName) & "   "
      count = count + 1
      If count Mod 10 = 0 Then txt = txt & cr
      rsWards.MoveNext
   Loop
   End If
   If Trim$(txt$) = "" Then txt$ = "    Not Stocked on any wards."
   rsWards.Close
   Set rsWards = Nothing
   replace txt$, "&", Chr(160), 0
   replace txt$, Chr(160), "&&", 0

DisplayScreen4_Exit:
   Me.FraInfoLarge.Caption = "   Stocked on the following wards"
   Me.LblInfoLarge.Caption = txt$
   Me.FraInfoLarge.Visible = True
   Me.FraInfoTop.Visible = False
   Me.FraInfoMiddle.Visible = False
Exit Sub

DisplayScreen4_Err:
   txt$ = "Cannot read ward stock database" & cr & "(Error " & Err & " " & Error$ & ")"
Resume DisplayScreen4_Exit

End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    
   KeyActions (KeyAscii)

End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)

   Select Case KeyCode
      Case KEY_F2: KeyF2
      Case KEY_F4: MechDispStockEnquiry
      End Select

End Sub

Private Sub Form_Load()
'ODrugInfo$ set to "" if drug not found
'10Dec97 EAC format d.outstanding to two decimal places
'29Dec97 EAC Use Stores drug description
'26May98 CFY Added Dp! to correct rounding errors in stock levels before displaying
'18Aug98 TH  Removed condition so as to show 0 priced items
'23Nov98 TH  Added Date last ordered and date last issued to Info panels
'22Jan99 TH  Format stocklevel in packs to two decimal places
'26Jan99 TH  Changed layout of received lstbox - still needs work but is improvement
'23Feb99 TH  Added Cr Affix to make credits more obvious
'08Mar99 TH  Added site abbreviation to title bar
'17May99 AE  Improved formatting of d.leadtime on screen
'    "       More sensible formatting of d.stocklvl on screen
'15Sep00 TH  Format stocklevel to 6 sig places
'20Sep00 TH  Addition to above change
'18Sep00 TH  Added Dp to format of qty received

Dim found As Integer, desc$
Dim font As String

   font = "Courier New"
   SetChrome Me
   '23Nov05 TH added to restore the fonts
   LstInfoTop.FontName = font
   LstInfoTop.FontSize = 8.25
   FraInfoTop.FontName = font
   FraInfoTop.FontSize = 8.25
   LstInfoMiddle.FontName = font
   LstInfoMiddle.FontSize = 8.25
   FraInfoMiddle.FontName = font
   FraInfoMiddle.FontSize = 8.25
   LblInfoLarge.FontName = font  '17oct08 CKJ
   LblInfoLarge.FontSize = 8.25  '   "
   '------------
   orddebug = False
   drug$ = Trim$(ODrugInfo$)
   strRobotStock = ""

   findrdrug drug$, 1, d, DrugPtr&, found, 2, False, False
   
   If found Then
      desc$ = Trim$(d.DrugDescription)	' desc$ = Trim$(GetStoresDescription()) XN 4Jun15 98073 New local stores description
      plingparse desc$, "!"
      If Len(Trim(hospabbr$)) Then
         desc$ = desc$ & "  (Site: " & Trim$(hospabbr$) & ")"
      Else
         desc$ = desc$ & "  (" & Trim$(hospname1$) & ")"
      End If
      Me.Caption = desc$
      m_intScreenNumber = 1
      DisplayScreen1or2 m_intScreenNumber
      DisplayPanel
      CentreForm Me
   Else
      Me.Hide
      If Not k.escd Then
         popmessagecr "!Item Enquiry", drug$ & " Not Found"
         k.escd = True
      End If
   End If

End Sub

Private Sub Form_Resize()
'11jul02 CKJ written

Dim lngsplitpoint As Long

   On Error Resume Next
   'xxxxx.move left, top, width, height
   picInfo.Move 0, Me.ScaleHeight - picInfo.Height, Me.ScaleWidth
   
   lngsplitpoint = picInfo.Top * 1 / 3
   
   FraInfoLarge.Move 0, 0, Me.ScaleWidth, picInfo.Top
   LblInfoLarge.Move 90, 270, FraInfoLarge.Width - 180, FraInfoLarge.Height - 405
   
   FraInfoTop.Move 0, 0, Me.ScaleWidth, lngsplitpoint
   LstInfoTop.Move 90, 270, FraInfoTop.Width - 180, FraInfoTop.Height - 315
   
   FraInfoMiddle.Move 0, FraInfoTop.Height, Me.ScaleWidth, picInfo.Top - FraInfoTop.Height
   LstInfoMiddle.Move 90, 270, FraInfoMiddle.Width - 180, FraInfoMiddle.Height - 315
   On Error GoTo 0
   
End Sub

Private Function FormatHeading(ByVal strHeadingNumber As String, ByVal strDefault As String) As String
'12Jul02 CKJ written

Dim strTemp As String

   strTemp = TxtD(dispdata$ & "\winord.ini", "ItemEnquiry", strDefault, "InfoPanelListTitle" & strHeadingNumber, False)
   replace strTemp, "[#####]", pad("(" & Trim$(d.PrintformV) & ")", 7), 0        '7 chars when padded
   FormatHeading = strTemp

End Function

Private Sub KeyActions(KeyAscii As Integer)
'16Jan98 EAC Handle Printing Requisitions in Packs
'12Jun98 CKJ Removed Format$(Val(...))    !!** Must check all instances of Format$(Val(...))
'30Jun98 EAC Handle part pack issues so that quantities aren't display as decimals
'30Jun98 EAC items that don't have an order num are shown as blank lines (ie Pick tick = N, Del Note = Y)
'28Aug98 TH  Formatted losses/gains so as to deal with negative values
'26Jan99 TH  Changed layout of received info
'23Feb99 TH  Added Cr Affix to make credits more obvious
'01Mar99 TH  Force retention of height of listboxes
'11Oct99 CKJ Removed Findsupplier
'18Sep00 TH  Added dp to format of received and outstanding quantities
'14Feb02 ATW Added Telephone number to page 3 of stock details under supplier name (ENHDB 1137)
'08Jul02 CKJ removed loops - use .Clear instead
'            moved almost all code to own procedures

Const procname$ = "KeyActions"

   Select Case KeyAscii
      Case 9 'tab
         If Me.LstInfoMiddle.Visible Then Me.LstInfoMiddle.SetFocus

      Case 27 'Escape
         Unload Me

      Case 13 'Enter
         m_intScreenNumber = m_intScreenNumber + 1
         If m_intScreenNumber = 5 Then m_intScreenNumber = 1
         
         'Fill the screen with data relevant to that particular screen
         Select Case m_intScreenNumber
            Case 1, 2: DisplayScreen1or2 m_intScreenNumber
            Case 3:    DisplayScreen3
            Case 4:    DisplayScreen4
            End Select

      Case 43                                      'Plus (+) key
         If Not orddebug Then
               orddebug = True
               popmessagecr "Drug Information", "Debugging is now ON."
            End If
   
      Case 45                                      'Minus (-) key
         If orddebug Then
               orddebug = False
               popmessagecr "Drug Information", "Debugging is now OFF."
            End If
   
      Case Else
         KeyAscii = 0
   
      End Select

End Sub

Private Sub KeyF2()
'29Dec97 EAC Use Stores drug description

   setinput 0, k
   EditDrugMsg DrugPtr&   ' 01Jun02 ALL/ATW

   If Not k.escd Then
         getdrug d, DrugPtr&, 0, False             '01Jun02 ALL/ATW
         DisplayPanel                              '09Jul02 CKJ moved all code to separate proc
      End If

End Sub

Private Sub LstInfoMiddle_KeyPress(KeyAscii As Integer)

   KeyActions (KeyAscii)

End Sub

Private Sub LstInfoMiddle_KeyUp(KeyCode As Integer, Shift As Integer)

   Select Case KeyCode
      Case KEY_F2: KeyF2
      Case KEY_F4: MechDispStockEnquiry
      End Select

End Sub

Private Sub LstInfoTop_KeyPress(KeyAscii As Integer)
    
   KeyActions (KeyAscii)

End Sub

Private Sub LstInfoTop_KeyUp(KeyCode As Integer, Shift As Integer)

   Select Case KeyCode
      Case KEY_F2: KeyF2
      Case KEY_F4: MechDispStockEnquiry
      End Select

End Sub

Sub MechDispStockEnquiry()
'16jun05 CKJ Written, based on similar facility in find-a-drug screen

Dim strMachine As String
Dim strStock As String
Dim strMsg As String
Dim NumItems As Single
Dim strMessage As String

   strRobotStock = ""

   If MechDispEnquiry(d, strMachine, strStock, strMessage) Then
         strMsg = strMachine & " stock level" & crlf & crlf
         
         If Len(strStock) Then
               strMsg = strMsg & strStock & " "
               Select Case Val(d.convfact)
                  Case 1
                     strMsg = strMsg & Trim$(d.PrintformV) & plural$(Val(strStock))
                  Case Is > 1
                     strMsg = strMsg & "pack" & plural$(Val(strStock))
                     NumItems = Val(strStock) * Val(d.convfact)
                     strMsg = strMsg & crlf & Format$(NumItems) & " " & Trim$(d.PrintformV) & plural$(NumItems)
                  Case Else
                     strMsg = strMsg & "pack" & plural$(Val(strStock))
                  End Select

               strMsg = strMsg & crlf
            End If
         
         If Len(strMessage) Then strMsg = strMsg & crlf & strMessage & crlf

      Else
         If strMachine = "<UNKNOWN>" Then
               strMsg = "Dispensing machine not specified for this item"
            Else
               strMsg = strMachine & " not available" & crlf & crlf & strMessage    'Shows 'Swisslog' or 'Rowa' if it should have linked but could not
            End If
      End If

   strRobotStock = strStock
   DisplayPanel
   popmessagecr "#", strMsg

End Sub

