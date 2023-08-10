VERSION 5.00
Begin VB.Form ContractEditor 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Enter / Amend Contract Details"
   ClientHeight    =   5130
   ClientLeft      =   240
   ClientTop       =   1455
   ClientWidth     =   9075
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
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5130
   ScaleWidth      =   9075
   Begin VB.Frame Frame3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H00000000&
      Height          =   2595
      Index           =   3
      Left            =   7860
      TabIndex        =   7
      Top             =   2580
      Width           =   1215
      Begin VB.PictureBox CmdButton 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         FillColor       =   &H8000000F&
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   375
         Left            =   180
         ScaleHeight     =   345
         ScaleWidth      =   885
         TabIndex        =   8
         Top             =   600
         Width           =   915
      End
      Begin VB.TextBox TxtUpdDate 
         Appearance      =   0  'Flat
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   60
         MaxLength       =   10
         TabIndex        =   3
         Text            =   "22/03/1996"
         Top             =   2040
         Width           =   1095
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Date of Change"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   435
         Left            =   120
         TabIndex        =   2
         Top             =   1560
         Width           =   975
      End
   End
   Begin VB.Frame Frame3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H00000000&
      Height          =   2595
      Index           =   2
      Left            =   7860
      TabIndex        =   6
      Top             =   0
      Width           =   1215
      Begin VB.CommandButton cmd1 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "E&xit"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   1
         Left            =   180
         TabIndex        =   10
         Top             =   1320
         Width           =   915
      End
      Begin VB.CommandButton cmd1 
         Appearance      =   0  'Flat
         Caption         =   "&Save"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   0
         Left            =   180
         TabIndex        =   9
         Top             =   720
         Width           =   915
      End
   End
   Begin VB.Frame Frame3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "New Contract Details"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   2595
      Index           =   1
      Left            =   0
      TabIndex        =   5
      Top             =   2580
      Width           =   7875
      Begin VB.TextBox TxtEdit 
         Appearance      =   0  'Flat
         Height          =   2235
         Index           =   1
         Left            =   180
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   1
         Top             =   240
         Width           =   7515
      End
   End
   Begin VB.Frame Frame3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Current Contract Details"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   2595
      Index           =   0
      Left            =   0
      TabIndex        =   4
      Top             =   0
      Width           =   7875
      Begin VB.TextBox TxtEdit 
         Appearance      =   0  'Flat
         Height          =   2175
         Index           =   0
         Left            =   180
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   0
         Top             =   240
         Width           =   7515
      End
   End
End
Attribute VB_Name = "ContractEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'--------------------------------------------------------------------------------------------
'            CTRACT.FRM
'
'     ?? EAC Written
' 6May97 CKJ Simplified sections, replaced mh3b200 with mhcm200 a lighter weight control
'            Dynaset is now closed on exit, bookmark used instead of closing & reopening
'29Jun97 EAC Use SupDB in place of WSDB
'22Aug97 CKJ DoneOnce% was Static in the activate event - however it was not cleared when
'            form was unloaded and remained set True for next call.
'03May98 CKJ Y2K. Mod to date entry field for 2 digit years - now uses 19080-2079
'20Sep98 CFY/TH Form_activate: Added extra field entries to stop error on db update
'11Mar99 CFY Changed to use Windows Colours
'--------------------------------------------------------------------------------------------


Option Explicit
DefInt A-Z
                                                       
Const modulename$ = "CTRACT.FRM"


Dim SavedCurrent As String, SavedNew As String, SavedDate$
Dim doneonce%                 '22Aug97 CKJ was Static in the activate event
Dim supcode$

Private Sub cmd1_Click(Index As Integer)

Const procname$ = "Cmd1_Click"
Dim ans$, NotSaved%, valid%, OkToExit%, resumeval%, retries%
Dim RsExtraSupplierData As ADODB.Recordset
Dim strParams As String
Dim lngResult As Long

   Select Case Index
      Case 0 'Save
         '!!** check that a valid date has been entered '@~@~
''         ContractDyn.Edit
''         ContractDyn!CurrentContractData = TxtEdit(0)
''         ContractDyn!NewContractData = TxtEdit(1)
''         ContractDyn!DateofChange = TxtUpdDate
''         On Error GoTo CBUpdateTableErr
''         ContractDyn.Update
''         On Error GoTo 0

         '21Jul14 TH Replaced below
         If sup.suppliertype = "E" Then
            strParams = gTransport.CreateInputParameterXML("WSupplier2ID", trnDataTypeint, 4, sup.SupplierID) & _
                        gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, TxtEdit(0)) & _
                        gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, TxtEdit(1)) & _
                        gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, TxtUpdDate)
            lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "WSupplier2ExtraDataNotesWrite", strParams)
                     
         Else
            popmessagecr "!Error", "Only external suppliers can have contract details. Editor incorrectly configured"
         End If
         
         'Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(supcode$)
         'If RsExtraSupplierData.RecordCount < 1 Then
         '
         '   'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
         '   'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
         '   'blnInsert = True
         '   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
         '               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, supcode$) & _
         '               gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, TxtEdit(0)) & _
         '               gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, TxtEdit(1)) & _
         '               gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, TxtUpdDate) & _
         '               gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, " ") & _
         '               gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, " ") & _
         '               gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
         '   lngResult = gTransport.ExecuteInsertSP(g_SessionID, "WExtraSupplierData", strParams)
         'Else
         '   'RsExtraSupplierData!ContactName1 = Trim$(contname1$)
         '   'RsExtraSupplierData!ContactName2 = Trim$(contname2$)
         '   'tempdyn.Edit
         '   strParams = gTransport.CreateInputParameterXML("WExtraSupplierDataID", trnDataTypeint, 4, RtrimGetField(RsExtraSupplierData!WExtraSupplierDataID)) & _
         '               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
         '               gTransport.CreateInputParameterXML("Supcode", trnDataTypeVarChar, 5, RtrimGetField(RsExtraSupplierData!supcode)) & _
         '               gTransport.CreateInputParameterXML("CurrentContractData", trnDataTypeVarChar, 1024, TxtEdit(0)) & _
         '               gTransport.CreateInputParameterXML("NewContractData", trnDataTypeVarChar, 1024, TxtEdit(1)) & _
         '               gTransport.CreateInputParameterXML("DateofChange", trnDataTypeVarChar, 10, TxtUpdDate) & _
         '               gTransport.CreateInputParameterXML("ContactName1", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName1)) & _
         '               gTransport.CreateInputParameterXML("ContactName2", trnDataTypeVarChar, 50, RtrimGetField(RsExtraSupplierData!ContactName2)) & _
         '               gTransport.CreateInputParameterXML("Notes", trnDataTypeVarChar, 1024, supnotes$)
         '   lngResult = gTransport.ExecuteUpdateSP(g_SessionID, "WExtraSupplierData", strParams)
         'End If
         SavedCurrent = TxtEdit(0)
         SavedNew = TxtEdit(1)
         SavedDate$ = TxtUpdDate
         

      Case 1 'Exit
         If SavedCurrent <> TxtEdit(0) Then NotSaved = True
         If SavedNew <> TxtEdit(1) Then NotSaved = True
         If SavedDate$ <> TxtUpdDate Then NotSaved = True

         If NotSaved Then
               k.escd = False
               ans$ = "Y"
               Confirm "Exiting", "exit without saving", ans$, k
               If ans$ = "Y" And Not k.escd Then
                     OkToExit = True
                  Else
                     OkToExit = False
                  End If
            Else
               OkToExit = True
            End If

         If OkToExit Then Unload Me

      End Select

Exit Sub

CBUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)
   Select Case resumeval
      Case -1: Resume
      Case 0:  Resume Next
      Case 1:  Close: StoresEnd    '@~@~ TerminateApp
      End Select
   
End Sub

Private Sub CmdButton_Click()

   TxtEdit(1) = TxtEdit(0)
   
End Sub

Private Sub Form_Activate()

'29Jun97 EAC Use SupDB in place of WSDB
'20Sep98 CFY/TH Added extra field entries to stop error on db update

Const procname$ = "Form_Activate"
Dim SQL$, resumeval%, retries%
Dim RsExtraSupplierData As ADODB.Recordset


   If Not doneonce Then
         supcode$ = Me.Tag
      Else
         Exit Sub
      End If

   If Trim$(supcode) = "" Then
         popmessagecr "EMIS Health", "Cannot show contract details - Supplier code missing"
         Unload Me
      Else
         'sql$ = "SELECT DISTINCTROW  * FROM ExtraSupplierData WHERE Supcode = '" & sup.code & "';"
''         SQL$ = "SELECT * FROM ExtraSupplierData WHERE Supcode = '" & supcode$ & "';"
''         Set ContractDyn = SupDB.CreateDynaset(SQL$) '29Jun97 EAC Use SupDB in place of WSDB
''         ContractDyn.LockEdits = False

         'if no match found then add one for this supplier
         Set RsExtraSupplierData = GetSupplierExtraDetailsSQL(supcode$)
                  If RsExtraSupplierData.RecordCount < 1 Then
''         If ContractDyn.EOF Then
''               ContractDyn.AddNew
''               ContractDyn!supcode = supcode$
''               ContractDyn!CurrentContractData = ""
''               ContractDyn!NewContractData = ""
''               ContractDyn!DateofChange = ""
''               ContractDyn!ContactName1 = ""   '20Sep98 CFY/TH Added
''               ContractDyn!ContactName2 = ""   '20Sep98 CFY/TH   '
''               On Error GoTo CFUpdateTableErr
''               ContractDyn.Update
''               ContractDyn.Bookmark = ContractDyn.LastModified
''               On Error GoTo 0
''            End If
                     SavedCurrent = ""
                     SavedNew = ""
                     SavedDate$ = ""
                  Else

                     SavedCurrent = RtrimGetField(RsExtraSupplierData!CurrentContractData)
                     SavedNew = RtrimGetField(RsExtraSupplierData!NewContractData)
                     SavedDate$ = RtrimGetField(RsExtraSupplierData!DateofChange)
                     RsExtraSupplierData.Close
                  End If
         Set RsExtraSupplierData = Nothing
         TxtEdit(0) = SavedCurrent
         TxtEdit(1) = SavedNew
         TxtUpdDate = SavedDate$
      End If
   doneonce = True

Exit Sub

CFUpdateTableErr:
   resumeval = ProcessUpdateErr(Err, modulename$, procname$, 0, retries)
   Select Case resumeval
      Case -1: Resume
      Case 0:  Resume Next
      Case 1:  Close: StoresEnd       '@~@~  TerminateApp
      End Select

End Sub

Private Sub Form_Load()
'@~@~ No explicit params - and sup is not global from Stkmaint

Const procname$ = "Form_Load"
   SetChrome Me
   ''CmdButton.Caption = "&Copy" & cr & "Current"
   CentreForm Me

End Sub

Private Sub Form_Unload(Cancel As Integer)
''
''   On Error Resume Next
''   ContractDyn.Close
''   Set ContractDyn = Nothing
''   On Error GoTo 0
   doneonce = False      '22Aug97 CKJ added

End Sub

Private Sub TxtUpdDate_KeyPress(KeyAscii As Integer)

Dim newdate$, parseddate$, valid%
         
   Select Case KeyAscii
      Case 13
         KeyAscii = 0
         newdate$ = TxtUpdDate
         parsedate newdate$, parseddate$, "1-", valid '03May98 CKJ Y2K was "2-" ie "dd-mm-yy"
         If valid Then
               TxtUpdDate = parseddate$
            Else
               BadDate
               TextBoxHiLight
            End If

      Case 27
         KeyAscii = 0
         Unload Me

      End Select

End Sub

