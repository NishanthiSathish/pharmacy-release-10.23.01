VERSION 5.00
Begin VB.UserControl ucProdStockEd 
   BackColor       =   &H00FFFFC0&
   ClientHeight    =   12690
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   13050
   ScaleHeight     =   12690
   ScaleWidth      =   13050
   Begin VB.PictureBox Picture1 
      Height          =   12735
      Left            =   0
      ScaleHeight     =   12675
      ScaleWidth      =   13035
      TabIndex        =   0
      Top             =   0
      Width           =   13095
      Begin VB.ListBox Lstbox 
         Height          =   5715
         Left            =   600
         TabIndex        =   3
         Top             =   2160
         Width           =   4935
      End
      Begin VB.Label lblTitle 
         Alignment       =   2  'Center
         Height          =   735
         Left            =   360
         TabIndex        =   5
         Top             =   720
         Width           =   5415
      End
      Begin VB.Label lblStatus 
         Height          =   495
         Index           =   0
         Left            =   960
         TabIndex        =   4
         Top             =   840
         Width           =   4575
      End
      Begin VB.Label lblMode 
         Height          =   495
         Left            =   1080
         TabIndex        =   2
         Top             =   8400
         Width           =   3615
      End
      Begin VB.Label LblProductLevel 
         Height          =   495
         Left            =   2760
         TabIndex        =   1
         Top             =   1440
         Width           =   2655
      End
   End
End
Attribute VB_Name = "ucProdStockEd"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
''Dim d As DrugParameters

Public Function RefreshState(ByVal SessionID As Long, ByVal ProductID As Long) As Boolean
'06Apr16 XN trimed LocalDescription before comparing it to "" 149885

Dim blnOK As Boolean
Dim rs As ADODB.Recordset
Dim strParams As String
Dim strDesc As String

   gDispSite = 2
   gEntityID_User = gTransport.ExecuteSelectReturnSP(g_SessionID, "pEntityIDFromSessionID", "")
   strParams = gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pPersonSelect", strParams)
   If Not rs Is Nothing Then
      If rs.State = adStateOpen Then
         If rs.RecordCount <> 0 Then
            UserID = RtrimGetField(rs!initials)
            UserFullName = Trim$(RtrimGetField(rs!title) & " " & RtrimGetField(rs!forename) & " " & RtrimGetField(rs!surname))
         End If
         rs.Close
      End If
      Set rs = Nothing
   End If
   ReadSiteInfo
   UserControlIsAlive = 1
   'First we need to check if this is a) an existing product in AMPP_Mapper, or a new product AT THE AMPP LEVEL !
   blnOK = CheckAMPPMapped(ProductID)
   
   
   If Not blnOK Then
      blnOK = isAMPP(ProductID)
   End If
   
   If blnOK Then  'Only Fire up if this is at an acceptable level or it has an existing row
   
   blnOK = GetProductNLbyProductID(ProductID, d)
   d.ProductID = ProductID 'This must be initialised for a product addition
   strDesc = Iff(Trim$(d.LocalDescription)="",d.storesdescription,d.LocalDescription) ' d.storesdescription XN 9Jun15 98073 New local stores description   
   plingparse strDesc, "!"
   lblTitle.Caption = strDesc
 
   SelectView
   End If
End Function
Sub UCsetcolours()

Dim ctrl As Control


   
   For Each ctrl In Controls
'      Select Case ctrl.ForeColor
'         Case &H80000008
'         Case &H8000000A
'         Case &H80000005
'         End Select
      
'      ctrl.BackColor = &HFFE3D6     'main background
'      ctrl.BackColor = &HC0C0C0     'silver
'      ctrl.BackColor = &HB48246     'bit darker blue
'      ctrl.BackColor = &HA97868     'another blue
'      ctrl.BackColor = &HF0D3C6     'and another
'      ctrl.BackColor = &HE6E0B0     'Paler blue
      
      On Error GoTo ErrorHandler
      
      Select Case ctrl.BackColor
         Case &H80000008
''            Stop
         Case &H8000000A, &HC0C0C0
            ctrl.BackColor = &HFFE3D6
         Case &H8000000F
            ctrl.BackColor = &HFFE3D6
         Case &H80000005, &HFFFFFF
            'white is fine for text boxes
         Case Else
''            Debug.Print Hex(ctrl.BackColor), ctrl.name
''            Stop
         End Select
            
      Select Case ctrl.name
         Case "Lbldays", "TxtLabel", "Label2", "Label4"
            'no change
         Case Else
            ctrl.FontName = "Arial"
         End Select
         
Continue:
   Next
Exit Sub

ErrorHandler:
Resume Continue

End Sub

'Injection/Infusion prescription
'-------------------------------
'prescriptiontypedescription=Infusion
'
'PrescriptionInfusion table
'  (RequestID)
'  UnitID_InfusionDuration
'  UnitID_RateMass
'  UnitID_RateTime
'  Continuous
'  InfusionDuration
'  InfusionDurationLow
'  Rate
'  RateMin
'  RateMax
'
'

Public Function SetConnection(ByVal SessionID As Long, ByVal AscribeSiteNumber As Long) As Boolean
'09May05 CKJ Main procedure to initialise the database connection

Dim objPhaRTL As PHARTL10.Security
Dim ConnectionString As String
Dim valid As Boolean

Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "SetConnection"

   On Error GoTo ErrorHandler

   If SessionID = 0 Then Err.Raise 32767, ErrSource, "Invalid SessionID (Zero)"
   If AscribeSiteNumber = 0 Then Err.Raise 32767, ErrSource, "Invalid SiteNumber (Zero)"
   
   g_SessionID = SessionID
   SiteNumber = AscribeSiteNumber
        
   If Val(Right$(date$, 4)) < 2005 Then
      Err.Raise 32767, ErrSource, "The clock in this computer has been set to " & date$ & cr & "Please correct the date on this computer"
   End If
        
   valid = False
   If Not gTransport Is Nothing Then
      If Not gTransport.Connection Is Nothing Then
         If gTransport.Connection.State = adStateOpen Then
            valid = True
         End If
      End If
   End If
    
   If Not valid Then
      Set objPhaRTL = CreateObject("PHARTL10.Security")
      ConnectionString = objPhaRTL.GetConnectionString(SessionID)
      Set objPhaRTL = Nothing
      
      If ConnectionString <> "" Then
         Set gTransport = New PharmacyData.Transport
         Set gTransport.Connection = New ADODB.Connection
         gTransport.Connection.Open ConnectionString

         gDispSite = GetLocationID_Site(SiteNumber)

         ReadSiteInfo
          
         App.HelpFile = AppPathNoSlash() & "\ASCSHELL.HLP"

         valid = True
         UCsetcolours
      End If
   End If
   
Cleanup:
   If ErrNumber Then
      On Error Resume Next
      gTransport.Connection.Close
      Set gTransport.Connection = Nothing
      Set gTransport = Nothing
      On Error GoTo 0
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, Format$(ErrNumber) & " " & ErrSource
   End If
   
''   If valid Then
''      lblStatus.Caption = " Connected "
''   Else
''      UserControlEnable False
''      lblStatus.Caption = " Unable to connect "
''   End If
   SetConnection = valid
Exit Function

ErrorHandler:
   ErrNumber = Err.Number
'   ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Function

Private Sub Command2_Click()

End Sub

Private Sub LstBox_Click()
Dim ViewNumber As Integer
Static LastView As Integer
Const Stkmaint$ = "\stkmaint.ini"
Dim ViewName$
Dim NumOfEntries As Integer
Dim intloop As Integer
Dim tmp$
Dim ptr As Integer
Dim Info$, Summary$
Dim SomeChange As Boolean
Dim dcop As DrugParameters
Dim dwas$
Dim TotFields As Integer
Dim Numoflines As Integer

ReDim lines$(2)





ViewNumber = LstBox.ItemData((LstBox.ListIndex))
tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", Format$(ViewNumber), 0)
      deflines tmp$, lines$(), ",", 0, Numoflines
     
ViewName$ = lines$(0)
ViewSelected ViewNumber, ViewName$


''           TotFields = Val(TxtD(dispdata$ & Stkmaint$, "data", "0", "Total", 0))
''         If TotFields = 0 Then
''               ''popmessagecr "Error", "Cannot find Stock Maintenance configuration file; " & Stkmaint$
''               Exit Sub
''            End If
''
''         ReDim presentent$(TotFields)
''
''   dcop = d
''   LSet r = d
''   dwas$ = Left$(r.record, Len(d))
''   StructToArray
''   Summary$ = ""
''
''
''            If Not k.escd Then                                      '??jul99 AE added if...
''                  ''setmodulardrug d
''                  LastView = ViewNumber
''                  ConstructView dispdata$ & Stkmaint$, "Views", "Data", ViewNumber, "0", 0, ViewName$, NumOfEntries
''                  Ques.Caption = ViewName$ & " - Number" & Str$(LstBox.ListIndex)
''                  For intloop = 1 To NumOfEntries
''                      QuesSetText intloop, RTrim$(presentent$(Val(Ques.lblDesc(intloop).Tag)))
''                  Next
''                  QuesMakeCtrl 0, 1000                 '12Aug97 CKJ Show print button
''
''                  QuesCallbackMode = 10
''                  QuesShow NumOfEntries                '<== Edit now
''                  QuesCallbackMode = 0
''
''                  For intloop = 1 To NumOfEntries
''                     tmp$ = QuesGetText(intloop)
''                     ptr = Val(Ques.lblDesc(intloop).Tag)
''                     If tmp$ <> RTrim$(presentent$(ptr)) Then
''                           '17Jul97 CKJ Add cr if line is long
''                           'info$ = pad$((Ques.lblDesc(i)), 25) & " " & "Was : '" & RTrim$(presentent$(Ptr)) & "' Now : '" & tmp$ & "'"
''                           info$ = pad$((Ques.lblDesc(intloop)), 25) & " " & "Was : '" & RTrim$(presentent$(ptr)) & "'"
''                           If Len(RTrim$(presentent$(ptr))) + Len(tmp$) > 50 Then info$ = info$ & cr & Space$(25)
''                           info$ = info$ & " Now : '" & tmp$ & "'"
''                           Summary$ = Summary$ & info$ & cr
''                           SomeChange = True
''                           'log changes here
''                           WriteLog rootpath$ + "\labutils.log", SiteNumber, UserID$, d.SisCode & " " & info$
''                        End If
''                     presentent$(ptr) = tmp$
''                  Next
''                  'If Len(Summary$) Then popmessagecr "", Summary$    'for debugging
''                  Unload Ques
''                  '''If FixedView Then ViewNumber = 0     'exit
''
''                  '09Jul99 AE Added block IF
''''                  If PkView Then
''''                        If Not SomeChange Then
''''                              RegEdited = False                        'Clear if no changes made, so we can view
''''                              ClearDkinStruct                          'another regimen
''''                              StructtoArrayKinetics                    '   "
''''                           Else
''''                              ArrayToKineticsStruct                    'otherwise, store the changes
''''                           End If                                      '   "
''''                     End If                                            '   "
''''                  '---------
''               End If                                                  '??Jul99AE Added

End Sub




Sub SelectView()
'find categories & offer a choice to the user, read from stkmaint.ini
'secondary barcodes are offered at the end of the list
' returns ViewChosen = 0 user escaped
'                      1 to n for View chosen
'                     -1 secondary barcodes
' 8Apr97 CKJ Added SuppInfo
'15Oct97 CKJ Added log view to list
'??Jul99 AE  Additions; only show pharmacokinetics view if it is enabled in the licence file

'!!** add passwording

Dim found%, TotCats%, i%, tmp$, Numoflines%
Const Stkmaint$ = "\stkmaint.ini"


   

 
 
   ReDim lines$(2)
   TotCats = Val(TxtD(dispdata$ & Stkmaint$, "views", "0", "Total", found))
   'If TotCats = 0 Then
   '      popmessagecr "Error", "Cannot find Stock Maintenance configuration file; " & Stkmaint$
   '      Exit Sub
   '   End If

   'Me.Caption = "Stock Maintenance"
   'Me.lblTitle = SuppInfo$ & cr & "Select category to view" & cr
   'Me.lblHead = ""
   
   For i = 1 To TotCats
      tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", Format$(i), found)
      deflines tmp$, lines$(), ",", 0, Numoflines
      LstBox.AddItem lines$(0)
      LstBox.ItemData(LstBox.NewIndex) = i
   Next

   'If PKEnabled() Then
   '      tmp$ = TxtD(dispdata$ & Stkmaint$, "views", "", "1002", found)        '       "
   '      If found Then                                                         '       "
   '            deflines tmp$, lines$(), ",", 0, numoflines                     '       "
   '            LstBoxFrm.LstBox.AddItem lines$(0)                              '       "
   '            LstBoxFrm.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = 1002     '       "
   '         End If                                                             '       "
   '   End If                                                                   '       "
   'Unload frmMsgWin                                                            '       "
   
   LstBox.AddItem "Secondary barcodes"
   LstBox.ItemData(LstBox.NewIndex) = -1
   LstBox.AddItem "View issues/returns for this item"     '15Oct97 CKJ Added
   LstBox.ItemData(LstBox.NewIndex) = -2        '   "
   LstBox.AddItem "View orders/receipts for this item"    '   "
   LstBox.ItemData(LstBox.NewIndex) = -3        '   "
   ''If FullAccess And fileexists(dispdata$ & "\restrict.idx") Then                   '15Jul98 CKJ Added
   ''      Me.LstBox.AddItem "Set General Import Restrictions for this item"   '   "
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -4                  '   "
   ''      Me.LstBox.AddItem "Set Specific Import Restrictions for this item"  '   "
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -5                  '   "
   ''  End If                                                                        '   "

   ''If ExternalPricingActive() Then ' 02May02 ATW Add extra option for external price DB
   ''      Me.LstBox.AddItem "Adjust catalogue price"
   ''      Me.LstBox.ItemData(LstBoxFrm.LstBox.NewIndex) = -6
   ''   End If
         
   ''For i = 0 To Lstbox.ListCount - 1
   ''   If Lstbox.ItemData(i) = DefaultView Then
   ''         Lstbox.ListIndex = i
   ''      End If
   ''Next
   ''LstBoxShow
   ''ViewChosen = 0
   ''If Me.LstBox.ListIndex > -1 Then
   ''      ViewChosen = Me.LstBox.ItemData(LstBoxFrm.LstBox.ListIndex)
   ''   End If
   '''Unload LstBoxFrm
   
   
End Sub

